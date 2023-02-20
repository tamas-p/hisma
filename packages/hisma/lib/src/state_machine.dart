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
class StateMachine<S, E, T> {
  // Map storing all state objects indexed by their state ids.
  StateMachine({
    required this.name,
    required this.initialStateId,
    required this.states,
    required this.transitions,
    this.events = const [],
    this.history,
    this.data,
  }) {
    _setIt();
  }

  static final _log = getLogger('$StateMachine');

  void _setIt() {
    states.forEach((_, state) async {
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
          // await region.machine.notifyMonitors();
        }
      }
    });

    _initMonitor();
    _log.info('SM $name created.');
  }

  void _initMonitor() {
    for (final monitorCreator in monitorCreators) {
      final monitor = monitorCreator.call(this);
      _log.info('notifyCreation for $monitor');
      _monitors.add(
        MonitorAndStatus(monitor: monitor, completed: monitor.notifyCreation()),
      );
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

  final _monitors = <MonitorAndStatus>[];
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
  /// We need to bubble the exitPointId (and the arg coming with the
  /// triggering event) up to the enclosing Region where exitConnectors will
  /// define the event that must be bubble up to the parent state and then
  /// state machine to fire with this event.
  Future<void> Function(Message)? notifyRegion;

  /// This callback is used notify this state machine by its children
  /// about state changes in those child machines. It is set to the
  /// parent StateMachine's [_processStateChangeNotification] method in
  /// parent's constructor. It is used to notify monitors up in the hierarchy.
  // Future<void> Function()? notifyParentAboutMyStateChange2;

  void notifyMonitors() {
    _log.fine('Notify from $name');
    for (final ms in _monitors) {
      // Before notifying a monitor we make sure that its initialization
      // (notifyCreation) has completed.
      ms.completed.then((value) {
        ms.monitor.notifyStateChange();
      });
    }
  }

  //----------------------------------------------------------------------------

  Future<void> start({
    S? entryPointId,
    dynamic arg,
    bool historyFlowDown = false,
  }) async {
    _log.fine(
      'start: machine:$name, state:$activeStateId, entryPointId:$entryPointId, arg:$arg, historyFlowDown:$historyFlowDown',
    );
    assert(_activeStateId == null, 'Machine ($name) is already started.');
    if (_activeStateId != null) return;

    if (historyFlowDown) {
      await _enterState(
        stateId: _historyStateId ?? initialStateId,
        arg: arg,
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
            arg: arg,
            historyFlowDown: state.level == HistoryLevel.deep,
          );
        } else {
          await _enterState(
            stateId: initialStateId,
            arg: arg,
            historyFlowDown: false,
          );
        }
      } else if (state is EntryPoint<E, T, S>) {
        final transitionWithId =
            await _selectTransition(state.transitionIds, arg);
        assert(transitionWithId != null);
        if (transitionWithId == null) return;
        // Need to set here as it is used as part of the Trigger.
        _activeStateId = entryPointId;
        await _executeTransition(transitionWithId: transitionWithId, arg: arg);
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
        arg: arg,
        historyFlowDown: history == HistoryLevel.deep || historyFlowDown,
      );
    } else {
      // As the last resort we start the machine with the initial state.
      await _enterState(
        stateId: initialStateId,
        arg: arg,
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
  Future<void> fire(E eventId, {dynamic arg, bool external = true}) async {
    _log.info('FIRE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    _log.info(
      'FIRE >>> machine: $name, state: $_activeStateId, : $eventId, arg: $arg, external: $external',
    );
    final changed = await _fire(eventId, arg: arg);
    _log.info(
      'FIRE <<< machine: $name, event: $eventId, arg: $arg, external: $external',
    );
    _log.info('FIRE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    _log.fine(
      '''
Changed: $changed
  monitors: $_monitors
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
  Future<bool> _fire(E eventId, {required dynamic arg}) async {
    _log.fine('START _internalFire');
    assert(_activeStateId != null, 'Machine has not been started.');
    if (_activeStateId == null) return false;

    final transitionWithId = await _getTransitionByEvent(eventId, arg);
    return _executeTransition(
      transitionWithId: transitionWithId,
      eventId: eventId,
      arg: arg,
    );
  }

  Future<bool> _executeTransition({
    required _TransitionWithId<S, T>? transitionWithId,
    E? eventId,
    required dynamic arg,
  }) async {
    if (transitionWithId == null) return false;

    await transitionWithId.transition.onAction?.action.call(this, arg);

    // Check if machine was stopped in an asynchronous operation.
    // Null eventId means that method is invoked from machine start()
    // when EntryPoint is used. In this case machine is not yet started.
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
      await stop(arg: arg);
    } else if (targetState is ExitPoint) {
      // First we stop this state machine.
      await stop(arg: arg);
      // Then we notify region that this (child) machine exited due to
      // reaching an exitPoint.
      await notifyRegion?.call(
        ExitNotificationFromMachine(
          exitPointId: transitionWithId.transition.to,
          arg: arg,
        ),
      );
    } else if (targetState is State) {
      final trigger = Trigger(
        source: _activeStateId,
        event: eventId,
        transition: transitionWithId.id,
      );
      await _exitState(arg: arg);
      await _enterState(
        trigger: trigger,
        stateId: transitionWithId.transition.to,
        arg: arg,
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

    if (_activeStateId != null) {
      result.add(_activeStateId);
      final state = states[_activeStateId];
      assert(
        state != null,
        'Could not find State by activeStateId: "$_activeStateId"',
      );
      assert(state is State<E, T, S>, 'State $state is not State type.');
      if (state is State<E, T, S>) {
        final regions = <dynamic>[];

        for (final region in state.regions) {
          final as = region.machine.getActiveStateRecursive();
          if (as.isNotEmpty) {
            regions.add(region.machine.getActiveStateRecursive());
          }
        }
        if (regions.isNotEmpty) result.addAll(regions);
      }
    }

    return result;
  }

  StateMachine<S1, E1, T1> find<S1, E1, T1>(String name) {
    final machine = _findIt(name);
    if (machine is! StateMachine<S1, E1, T1>) {
      throw HismaMachineNotFoundException(
        machine == null
            ? '$name machine is not found in ${this.name} hierarchy. '
            : '$name machine is not a StateMachine<$S1, $E1, $T1>.',
      );
    }
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
  Future<void> _exitState({required dynamic arg}) async {
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
    await state.onExit?.action.call(this, arg);
    await _exitRegions(state, arg);
  }

  // Stops child state machines of each region of a given state.
  Future<void> _exitRegions(State<E, T, S> state, dynamic arg) async {
    for (final region in state.regions) {
      if (region.machine.activeStateId != null) {
        await region.machine.stop(arg: arg);
      }
    }
  }

  /// Stopping the state machine also exiting active state and
  /// recursively stopping all potential child machines.
  Future<void> stop({required dynamic arg}) async {
    _log.fine('$name  stop, state:$activeStateId, arg:$arg');
    await _exitState(arg: arg);
    _activeStateId = null;
    notifyMonitors();
  }

  /// Enters state machine to the given state, executes onEntry() and
  /// invokes entering to regions defined in this state. Trigger that
  /// resulted the state change is passed to this method that in turn passes
  /// it to the method manages entering to the regions.
  Future<void> _enterState({
    Trigger<S, E, T>? trigger,
    required S stateId,
    required dynamic arg,
    required bool historyFlowDown,
  }) async {
    _log.fine(
      '> $name  _enterState, activeStateId:$activeStateId, trigger:$trigger, stateId:$stateId, arg:$arg, historyFlowDown:$historyFlowDown',
    );
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

    _log.fine('fire arg: $arg');
    try {
      await state.onEntry?.action.call(this, arg);
    } catch (e) {
      _log.severe('Exception during onEntry: $e');
    }
    await _enterRegions(
      trigger: trigger,
      state: state,
      arg: arg,
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
    required dynamic arg,
    required bool historyFlowDown,
  }) async {
    for (final region in state.regions) {
      final entryPointId = region.entryConnectors?[trigger];
      await region.machine.start(
        entryPointId: entryPointId,
        arg: arg,
        historyFlowDown: historyFlowDown,
      );
    }
  }

  /// Calculates which transition shall be used for the eventId parameter.
  Future<_TransitionWithId<S, T>?> _getTransitionByEvent(
    E eventId,
    dynamic arg,
  ) async {
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

    return _selectTransition(transitionIds, arg);
  }

  /// Calculates which transition shall be used from the list of transitions
  /// by looping though them and selecting the one with highest priority whose
  /// guard condition (or lack of it) allows it.
  Future<_TransitionWithId<S, T>?> _selectTransition(
    List<T> transitionIds,
    dynamic arg,
  ) async {
    _TransitionWithId<S, T>? selectedTransitionWithId;
    for (final transitionId in transitionIds) {
      final transition = transitions[transitionId];
      assert(
        transition != null,
        'Transition could not be found by $transitionId',
      );
      if (transition == null) continue;

      final guardAllows =
          await transition.guard?.condition.call(this, arg) ?? true;
      if (!guardAllows) continue;

      final now = DateTime.now();
      if (transition.minInterval != null &&
          transition.lastTime != null &&
          now.difference(transition.lastTime!) < transition.minInterval!) {
        _log.info('Throwing hismaIntervalException.');
        // TODO: Shall we drop or simply continue (selecting the transition)?
        throw HismaIntervalException(
          'Too little time passed since last transition: '
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
        'arg=${notification.arg}',
      );
      await fire(notification.event, arg: notification.arg, external: false);
    } else if (notification is StateChangeNotification) {
      _log.fine('$name  _processNotification: StateChangeNotification');
      notifyMonitors();
      // await notifyParentAboutMyStateChange?.call();
      await notifyRegion?.call(StateChangeNotification());
    } else if (notification is GetName) {
      notification.name = name;
    }
  }

  /// WARNING: Work in progress. Do not use it.
  /// TODO: Analyze and and create proper copyWith through all layers of the
  /// StateMachine class.
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

/// Helper class to hold both the monitor and the returned Future value of its
/// notifyCreation method. It is used in [notifyMonitors] to send
/// state change notification only after the notifyCreation was completed.
class MonitorAndStatus {
  MonitorAndStatus({
    required this.monitor,
    required this.completed,
  });
  Monitor monitor;
  Future<void> completed;
}
