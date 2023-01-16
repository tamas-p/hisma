import 'assistance.dart';
import 'hisma_exception.dart';
import 'monitor.dart';
import 'notification.dart';
import 'state.dart';
import 'transition.dart';
import 'trigger.dart';

typedef StateMap<S, E, T> = Map<S, BaseState<E, T, S>>;
typedef TransitionMap<T, S> = Map<T, Transition<S>>;
typedef MonitorGenerator = Monitor Function(
  StateMachine<dynamic, dynamic, dynamic>,
);

/// State machine engine
/// [S] State identifier type for the machine.
/// [E] State transition identifier type.
/// [T] Transition identifier type.
///
/// {@animation 100 200 https://flutter.github.io/assets-for-api-docs/assets/widgets/loading_progress_image.mp4}
class StateMachine<S, E, T> {
  // Map storing all state objects indexed by their state ids.
  StateMachine({
    required this.name,
    required this.initialStateId,
    required this.states,
    required this.transitions,
    this.events = const [],
    this.history,
  }) {
    setIt();
  }

  static final _log = getLogger('$StateMachine');

  void setIt() {
    states.forEach((_, state) {
      _log.fine('myName=$name');
      if (state is State<E, T, S>) {
        // TODO: Do ww need ?? here?
        state.notifyMachine ??= _processNotification;
        state.machine = this;
        // State
        // state.notifyStateChange = _pushStateMachine;
        // state.parentName = name;
        for (final region in state.regions) {
          // Region
          // region.notifyStateChange = _pushStateMachine;
          // region.parentName = name;
          // Machine
/*
          region.machine.notifyParentAboutMyStateChange =
              _processStateChangeNotification;
          region.machine.parentName = name;
*/
          // Since now we became the parent we must make sure that monitors of
          // child machines are notified about this change. Without this a
          // monitor that uses parentName would miss this change.
          _log.fine(
            '$name StateMachine $name constructor for ${region.machine.name}',
          );
          region.machine.notifyMonitors();
        }
      }
    });

    _initCompleted = initMonitor();
    _log.info('SM $name created.');
  }

  late Future<void> _initCompleted;

  Future<void> initMonitor() async {
    for (final monitorCreator in monitorCreators) {
      final monitor = monitorCreator.call(this);
      monitors.add(monitor);
      _log.info('Initializing $monitor');
      monitor.notifyCreation();
      _log.info('DONE Initializing $monitor');
    }
  }

  /// State machine name.
  final String name;

  /// OLD, TB Deleted:
  /// Name of the parent state machine if that exist, null otherwise.
  /// It can be used e.g. by state machine monitors that implement [Monitor]
  /// interface to register state machine to the visualization server under
  /// their parent state machine.
  // String? parentName;

  /// Returns name of the parent state machine if that exist, null otherwise.
  /// It can be used e.g. by state machine monitors that implement [Monitor]
  /// interface to display parent related actions for a state machine (e.g. in
  /// PlantUmlConverter in hisma_visual_monitor).
  String? get parentName {
    final nameMessage = GetName();
    notifyRegion?.call(nameMessage);
    // if (nameMessage.name != null) notifyMonitors();
    return nameMessage.name;
  }

  final S initialStateId;
  final StateMap<S, E, T> states;
  final TransitionMap<T, S> transitions;

  final monitors = <Monitor>[];
  static List<MonitorGenerator> monitorCreators = [];
  final List<E> events;
  final HistoryLevel? history;

  //----------------------------------------------------------------------------

  /// Convenience method to give back either a State or null.
  State<E, T, S>? stateAt(S stateId) {
    final state = states[stateId];
    return state is State<E, T, S> ? state : null;
  }

  //----------------------------------------------------------------------------

  /// Stores that identifier of the active state or null if state machine has
  /// not been started.
  S? _activeStateId;
  S? _historyStateId;

  //----------------------------------------------------------------------------

  /// This callback is invoked when transitioning to an [ExitPoint].
  /// It is implemented by the enclosing [Region].
  /// We need to bubble the exitPointId (and the data coming with the
  /// triggering event) up to the enclosing Region where exitConnectors will
  /// define the event that must be bubble up to the parent state and then
  /// state machine to fire with this event.
  Future<void> Function(Message)? notifyRegion;

  /// This callback is used notify this state machine by its children
  /// about state changes in those child machines. It is set to the
  /// parent StateMachine's [_processStateChangeNotification] method in
  /// parent's constructor. It is used to notify monitors up in the hierarchy.
  Future<void> Function()? notifyParentAboutMyStateChange2;

  Future<void> notifyMonitors() async {
    // Before notifying monitors make sure that their initialization
    // has completed.
    await _initCompleted;
    _log.fine('Notify from $name');
    for (final monitor in monitors) {
      monitor.notifyStateChange();
    }
  }

  //----------------------------------------------------------------------------

  Future<void> start({
    S? entryPointId,
    dynamic data,
    bool historyFlowDown = false,
  }) async {
    assert(_activeStateId == null, 'Machine ($name) is already started.');
    if (_activeStateId != null) return;

    if (historyFlowDown) {
      await _enterState(
        stateId: _historyStateId ?? initialStateId,
        data: data,
        historyFlowDown: true,
      );
    } else if (entryPointId != null) {
      // We have some kind of entryPoint (regular EntryPoint or
      // HistoryEntryPoint) to process. They have preference over
      // machine history and normal initial state.
      final state = states[entryPointId];
      assert(state != null);
      if (state == null) return;
      if (state is HistoryEntryPoint<E, T, S>) {
        if (_historyStateId != null) {
          await _enterState(
            stateId: _historyStateId as S,
            data: data,
            historyFlowDown: state.level == HistoryLevel.deep,
          );
        } else {
          await _enterState(
            stateId: initialStateId,
            data: data,
            historyFlowDown: false,
          );
        }
      } else if (state is EntryPoint<E, T, S>) {
        final transitionWithId = _selectTransition(state.transitionIds);
        assert(transitionWithId != null);
        if (transitionWithId == null) return;
        _activeStateId = entryPointId;
        await _executeTransition(transitionWithId: transitionWithId);
      } else {
        assert(
          false,
          'State defined by $entryPointId entryPointId is neither '
          'HistoryEntrypoint nor EntryPoint.',
        );
      }
    } else if (history != null) {
      // We now process default history setting of the machine. It has
      // preference over normal initial state.
      // historyTriggered = true;
      await _enterState(
        stateId: _historyStateId ?? initialStateId,
        data: data,
        historyFlowDown: history == HistoryLevel.deep || historyFlowDown,
      );
    } else {
      // As the last resort we start the machine with the initial state.
      await _enterState(
        stateId: initialStateId,
        data: data,
        historyFlowDown: false,
      );
    }
  }

  /// Holds data just passed with start() or fire() that is about to result
  /// machine to go to the next state.
  // dynamic _newData;

  /// Holds data passed with previous start() or fire() when machine
  /// entered to current state.
  // dynamic _oldData;

  /// [external] indicates if caller was external to this class. Defaults to
  /// true. Mainly (only?) internal invocations from StateMachine will set it
  /// to false to avoid notifying parent state machines about a state change as
  /// the original external fire will do that and this way we avoid sending
  /// multiple notifications for parent state machine about a state change.
  Future<void> fire(E eventId, {dynamic data, bool external = true}) async {
    _log.info('FIRE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    _log.info(
      'FIRE >>> machine: $name, event: $eventId, data: $data, external: $external',
    );
    final changed = await _internalFire(eventId, data: data);
    _log.info(
      'FIRE <<< machine: $name, event: $eventId, data: $data, external: $external',
    );
    _log.info('FIRE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    _log.fine(
      '''
Changed: $changed
  monitors: $monitors
  notifyStateChange: $notifyParentAboutMyStateChange2
  external: $external''',
    );
    if (changed && external) {
      // await pushStateMachine();
      // Notify parent that active state of
      // this state machine was changed.
      _log.fine('$name sending notifyRegion?.call(StateChangeNotification())');
      // await notifyParentAboutMyStateChange2?.call();
      await notifyRegion?.call(StateChangeNotification());
    }
  }

  /// Holds data arrived with [fire].
  /// TODO: Is it the best way to access data from the machine?
  dynamic data;

  /// Manages potential state transition based on the eventId parameter.
  /// It returns true if state change ocurred, false otherwise.
  Future<bool> _internalFire(E eventId, {required dynamic data}) async {
    this.data = data;
    _log.fine('START _internalFire');
    assert(_activeStateId != null, 'Machine has not been started.');
    if (_activeStateId == null) return false;

    final transitionWithId = _getTransitionByEvent(eventId);
    return _executeTransition(
      transitionWithId: transitionWithId,
      eventId: eventId,
    );
  }

  Future<bool> _executeTransition({
    required _TransitionWithId<S, T>? transitionWithId,
    E? eventId,
  }) async {
    if (transitionWithId == null) return false;

    await transitionWithId.transition.onAction?.action.call(this, data);
    // Machine was stopped in an asynchronous operation.
    // TODO: After all async operations we shall check if the machine is stopped
    // or its state already changed.
    // One way to manage it could be kind of transaction approach to state
    // machine state changes: it would be atomic - either succeed or dropped.
    // The 1st one that completes would win. This way state change could go
    // asynchronously, but the final atomic change would only happen if state
    // was not already changed by some other asynchronous operation.
    // This bellow only manages if the machine was stopped in another async
    // operation.
    //
    // Null eventId means that method is invoked from machine start()
    // when EntryPoint is used. In this case machine is not yet started.
    //
    // ignore: invariant_booleans
    if (eventId != null && _activeStateId == null) {
      _log.fine('Another asynchronous operation stopped our machine, '
          'we stop the transition.');
      return false;
    }

    final targetState = states[transitionWithId.transition.to];
    assert(
      targetState != null,
      'Target state is null identified by "${transitionWithId.transition.to}"',
    );
    if (targetState == null) return false;

    // From here we know active state will change.

    if (targetState is FinalState) {
      // TODO maybe combine with ExitPoint.
      // First we stop this state machine.
      await stop(data: data);
    } else if (targetState is ExitPoint) {
      // First we stop this state machine.
      await stop(data: data);
      // Then we notify region that this (child) machine exited due to
      // reaching an exitPoint.
      await notifyRegion?.call(
        ExitNotificationFromMachine(
          exitPointId: transitionWithId.transition.to,
          data: data,
        ),
      );
    } else if (targetState is State) {
      final trigger = Trigger(
        source: _activeStateId,
        event: eventId,
        transition: transitionWithId.id,
      );
      await _exitState(data: data);
      await _enterState(
        trigger: trigger,
        stateId: transitionWithId.transition.to,
        data: data,
        historyFlowDown: false,
      );
    } else {
      assert(
        false,
        'targetState shall be either '
        'ExitState or State but it is ${targetState.runtimeType}',
      );
    }

    // If we get to this point the activeState has changed.
    return true;
  }

  S? get activeStateId => _activeStateId;

  /// Creates an array representing the active states of this and
  /// recursively all compounded state machines where an array means
  /// one state machine where 1st item is the state identifier and this
  /// array can contain zero or more sub state machines (regions) that
  /// are again defined as an array:
  ///
  /// [
  ///   StateID.s2,
  ///   [
  ///     SubStateID.s1,
  ///     [SubSubStateID.work],
  ///     [SubSubStateID.work]
  ///   ],
  ///   [
  ///     SubStateID.s1,
  ///     [
  ///       SubSubStateID.s1,
  ///       [SubSubStateID.work],
  ///       [SubSubStateID.work],
  ///       [SubSubStateID.work],
  ///     ],
  ///     [
  ///       SubSubStateID.s1,
  ///       [SubSubStateID.work],
  ///       [SubSubStateID.work],
  ///     ]
  ///   ],
  ///   [
  ///     SubStateID.s1,
  ///     [SubSubStateID.work],
  ///     [SubSubStateID.work]
  ///   ]
  /// ];
  ///
  /// TODO: Add StateMachine.name to the activeStateId.
  List<dynamic> getActiveStateRecursive() {
    final result = <dynamic>[];
    result.add(_activeStateId);

    if (_activeStateId != null) {
      final state = states[_activeStateId];
      assert(
        state != null,
        'Could not find State by activeStateId: "$_activeStateId"',
      );
      assert(state is State<E, T, S>, 'State $state is not State type.');
      if (state is State<E, T, S>) {
        final regions = <dynamic>[];

        for (final region in state.regions) {
          regions.add(region.machine.getActiveStateRecursive());
        }
        if (regions.isNotEmpty) result.addAll(regions);
      }
    }

    return result;
  }

  StateMachine<S1, E1, T1> find<S1, E1, T1>(String name) {
    final machine = _findIt(name);
    // TODO: Create specific exception instead of Exception('') bellow.
    if (machine is! StateMachine<S1, E1, T1>) throw Exception('');
    return machine;
  }

  StateMachine<dynamic, dynamic, dynamic>? _findIt(String name) {
    if (this.name == name) {
      return this;
    } else {
      for (final state in states.values) {
        if (state is State<E, T, S>) {
          for (final region in state.regions) {
            final result = region.machine._findIt(name);
            if (result != null) {
              return result;
            } else {
              continue;
            }
          }
        }
      }
      return null;
    }
  }

  //----------------------------------------------------------------------------

  /// Returns target state (.to) of the EntryPoint identified by the
  /// entryPointId parameter. It is only in a separate method to have
  /// list of checks here thus resulting more readable code.
  //
  // This could be deleted as start() was refactored.
  //
  // S? _getTargetState(S entryPointId) {
  //   final entryPoint = states[entryPointId];
  //   assert(
  //     entryPoint != null,
  //     'EntryPoint can not be found by $entryPointId.',
  //   );
  //   if (entryPoint == null) return null;
  //   assert(
  //     entryPoint is EntryPoint<E, T, S>,
  //     'Object is not EntryPoint: $entryPoint by $entryPointId.',
  //   );
  //   if (entryPoint is! EntryPoint<E, T, S>) return null;
  //   final to = entryPoint.to;
  //   assert(
  //     to != null,
  //     'EntryPoint does not include to State ($entryPointId : $entryPoint).',
  //   );
  //   if (to == null) return null;

  //   return to;
  // }

  /// Exits from currently active state and also exits all region of the
  /// active state.
  Future<void> _exitState({required dynamic data}) async {
    // Commented out this assert to allow stop() to be invoked on a stopped
    // state machine:
    // assert(
    //   activeStateId != null,
    //   'activeStateId is null',
    // );
    if (activeStateId == null) return;
    final stateId = activeStateId as S;
    final state = states[stateId];
    assert(
      state != null,
      'State could not be found by state id "$activeStateId"',
    );
    if (state == null) return;
    assert(
      state is State<E, T, S> || state is EntryPoint,
      'state is not State or EntryPoint but ${state.runtimeType}',
    );
    if (state is! State<E, T, S>) return;
    await state.onExit?.action.call(this, data);
    await _exitRegions(state, data);
  }

  // Stops child state machines of each region of a given state.
  Future<void> _exitRegions(State<E, T, S> state, dynamic data) async {
    for (final region in state.regions) {
      if (region.machine.activeStateId != null) {
        await region.machine.stop(data: data);
      }
    }
  }

  /// Stopping the state machine also exiting active state and
  /// recursively stopping all potential child machines.
  Future<void> stop({required dynamic data}) async {
    await _exitState(data: data);
    _activeStateId = null;
    _log.fine('$name  stop');
    await notifyMonitors();
  }

  /// Enters state machine to the given state, executes onEntry() and
  /// invokes entering to regions defined in this state. Trigger that
  /// resulted the state change is passed to this method that in turn passes
  /// it to the method manages entering to the regions.
  Future<void> _enterState({
    Trigger<S, E, T>? trigger,
    required S stateId,
    required dynamic data,
    required bool historyFlowDown,
  }) async {
    _log.fine('> $name  _enterState');
    final state = states[stateId];
    assert(
      state != null,
      'State could not be found by state id "$stateId"',
    );
    if (state == null) return;
    assert(
      state is State<E, T, S>,
      'state is not State but ${state.runtimeType}',
    );
    if (state is! State<E, T, S>) return;

    _activeStateId = stateId;
    _historyStateId = _activeStateId;

    _log.fine('fireData: $data');
    try {
      await state.onEntry?.action.call(this, data);
    } catch (e) {
      _log.severe('Exception during onEntry: $e');
    }
    await _enterRegions(
      trigger: trigger,
      state: state,
      data: data,
      historyFlowDown: historyFlowDown,
    );

    _log.fine('< $name  _enterState');
    notifyMonitors();
  }

  /// For each region of [state] the state machine of a specific region is
  /// started with an entry point identifier or null if such identifier could
  /// not be found by trigger in the entryConnectors of the region.
  Future<void> _enterRegions({
    Trigger<S, E, T>? trigger,
    required State<E, T, S> state,
    required dynamic data,
    required bool historyFlowDown,
  }) async {
    for (final region in state.regions) {
      final entryPointId = region.entryConnectors?[trigger];
      await region.machine.start(
        entryPointId: entryPointId,
        data: data,
        historyFlowDown: historyFlowDown,
      );
    }
  }

  /// Calculates which transition shall be used for the eventId parameter.
  _TransitionWithId<S, T>? _getTransitionByEvent(E eventId) {
    final state = states[activeStateId];
    assert(
      state is State<E, T, S>,
      'state is not State but ${state.runtimeType}',
    );
    if (state is! State<E, T, S>) return null;

    final transitionIds = state.etm[eventId];
    assert(
      transitionIds != null,
      'Could not find transition ID list by "$eventId" for state "$activeStateId"',
    );
    if (transitionIds == null) return null;
    assert(
      transitionIds.isNotEmpty,
      'Transition ID list selected by $eventId is empty.',
    );
    if (transitionIds.isEmpty) return null;

    return _selectTransition(transitionIds);
  }

  /// Calculates which transition shall be used from the list of transitions
  /// by looping though them and selecting the one with highest priority whose
  /// guard condition (or lack of it) allows it.
  _TransitionWithId<S, T>? _selectTransition(List<T> transitionIds) {
    _TransitionWithId<S, T>? selectedTransitionWithId;
    for (final transitionId in transitionIds) {
      final transition = transitions[transitionId];
      assert(
        transition != null,
        'Transition could not be found by $transitionId',
      );
      if (transition == null) continue;

      final guardAllows = transition.guard?.condition.call() ?? true;
      if (!guardAllows) continue;

      final now = DateTime.now();
      if (transition.minInterval != null &&
          transition.lastTime != null &&
          now.difference(transition.lastTime!) < transition.minInterval!) {
        _log.info('Throwing hismaIntervalException.');
        // TODO: Shall we drop or simply continue (selecting the transition)?
        throw HismaIntervalException(
          reason: 'Too little time passed since last transition: '
              '${now.difference(transition.lastTime!)}',
        );
      }
      transition.lastTime = now;

      if (selectedTransitionWithId == null ||
          selectedTransitionWithId.transition.priority < transition.priority) {
        selectedTransitionWithId =
            _TransitionWithId(transition: transition, id: transitionId);
      }
    }

    return selectedTransitionWithId;
  }

  Future<void> _processNotification(Message notification) async {
    if (notification is ExitNotificationFromRegion<E>) {
      _log.info(
        '$name _processNotification: Notification event=${notification.event} '
        'data=${notification.data}',
      );
      await fire(notification.event, data: notification.data, external: false);
    } else if (notification is StateChangeNotification) {
      _log.fine('$name  _processNotification: StateChangeNotification');
      await notifyMonitors();
      // await notifyParentAboutMyStateChange?.call();
      await notifyRegion?.call(StateChangeNotification());
    } else if (notification is GetName) {
      notification.name = name;
    }
  }

  // TODO: Analyze and and create proper copyWith through all layers of the
  // StateMachine class.
  StateMachine<S, E, T> copyWith({
    String? name,
    S? initialStateId,
    StateMap<S, E, T>? states,
    TransitionMap<T, S>? transitions,
    List<E>? events,
    HistoryLevel? history,
  }) {
    return StateMachine<S, E, T>(
      name: name ?? this.name,
      initialStateId: initialStateId ?? this.initialStateId,
      states: states ??
          this.states.map((stateId, state) {
            if (state is State<E, T, S>) {
              return MapEntry(stateId, state.copyWith());
            } else {
              return MapEntry(stateId, state);
            }
          }),
      transitions: transitions ?? TransitionMap<T, S>.from(this.transitions),
      events: events ?? [...this.events],
      history: history ?? this.history,
    );
  }
}

/// Helper class to allow return both Transition and its ID from
/// the [_getTransitionByEvent] method.
class _TransitionWithId<S, T> {
  _TransitionWithId({
    required this.transition,
    required this.id,
  });

  Transition<S> transition;
  T id;
}
