import 'assistance.dart';
import 'hisma_exception.dart';
import 'monitor.dart';
import 'notification.dart';
import 'state.dart';
import 'transition.dart';
import 'trigger.dart';

typedef StateMap<S, E, T> = Map<S, BaseState<E, T, S>>;
typedef TransitionMap<T, S> = Map<T, Edge<S>>;
typedef MonitorGenerator = Monitor Function(
  Machine<dynamic, dynamic, dynamic>,
);

/// State machine engine
///
/// [S] State identifier type for the machine.
/// [E] State transition identifier type.
/// [T] Transition identifier type.
///
/// [strict] enables or disables strict mode. See [Machine.strict] for more
/// details.
class Machine<S, E, T> {
  // Map storing all state objects indexed by their state ids.
  Machine({
    required this.name,
    required this.initialStateId,
    required this.states,
    required this.transitions,
    this.events = const [],
    this.history,
    this.data,
    bool? strict,
  }) {
    _strict = strict ?? Machine.strict;
    _setIt();
  }

  static final _log = getLogger('$Machine');

  void _setIt() {
    states.forEach((_, state) async {
      _log.fine(() => 'myName=$name');
      if (state is State<E, T, S>) {
        // TODO: Do we need ?? here?
        state.notifyMachine ??= _processStateNotification;
        state.machine = this;
        for (final region in state.regions) {
          region.machine.parent = this;
        }
      }
    });

    _initMonitor();
    _log.info(() => 'SM $name created.');
  }

  void _initMonitor() {
    for (final monitorCreator in monitorCreators) {
      final monitor = monitorCreator.call(this);
      _log.info(() => 'notifyCreation for $monitor');
      _monitors.add(
        MonitorAndStatus(monitor: monitor, completed: monitor.notifyCreation()),
      );
    }
  }

  /// State machine name.
  final String name;

  /// Parent machine.
  Machine<dynamic, dynamic, dynamic>? parent;

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

  /// Stores last active state.
  S? _historyStateId;

  //----------------------------------------------------------------------------

  /// This callback is invoked when transitioning to an [ExitPoint].
  /// It is implemented by the enclosing [Region].
  /// We need to bubble the exitPointId (and the arg coming with the
  /// triggering event) up to the enclosing Region where exitConnectors will
  /// define the event that must be bubble up to the parent state and then
  /// state machine to fire with this event.
  Future<void> Function(Message)? notifyRegion;

  void _notifyMonitors() {
    _log.fine(() => 'Notify from $name');
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
  }) async {
    _log.fine(
      () => 'start: machine:$name, state:$activeStateId, '
          'entryPointId:$entryPointId, arg:$arg, '
          'historyFlowDown:${arg is _HistoryFlowDown}',
    );
    _cAssert(_activeStateId == null, 'Machine ($name) is already started.');
    if (_activeStateId != null) return;

    if (arg is _HistoryFlowDown) {
      await _enterState(
        stateId: _historyStateId ?? initialStateId,
        arg: arg.arg,
        historyFlowDown: true,
      );
    } else if (entryPointId != null) {
      // We have some kind of entryPoint (regular EntryPoint or
      // HistoryEntryPoint) to process. They have preference over
      // machine history and normal initial state.
      final state = states[entryPointId];
      assert(
        state is BaseEntryPoint,
        'State "$entryPointId" of machine named "$name" '
        'is an $state, but it should be a BaseEntryPoint.',
      );
      if (state == null) return;
      if (state is HistoryEntryPoint<E, T, S>) {
        await _enterState(
          stateId: _historyStateId ?? initialStateId,
          arg: arg,
          historyFlowDown:
              _historyStateId != null && state.level == HistoryLevel.deep,
        );
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
        historyFlowDown: history == HistoryLevel.deep,
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

  Future<void> fire(E eventId, {dynamic arg}) async {
    _log.info(
      () =>
          'fire start: machine: $name, state: $_activeStateId, event: $eventId, '
          'arg: $arg, external: ${arg is _Internal}',
    );
    final changed = await _fire(eventId, arg: arg is _Internal ? arg.arg : arg);
    _log.info(
      () => 'fire stop: machine: $name, event: $eventId, arg: $arg, '
          'external: ${arg is _Internal}',
    );
    _log.fine(
      () => 'Changed: $changed '
          'monitors: $_monitors '
          'external: ${arg is _Internal}',
    );
    if (changed && arg is! _Internal) {
      // Notify parent that active state of this machine was changed.
      _log.fine(() => '$name call _processMachineNotification');
      await parent?._processMachineNotification();
    }
  }

  /// Holds data arrived with [fire].
  /// TODO: Is it the best way to access data from the machine?
  dynamic data;

  /// Manages potential state transition based on the eventId parameter.
  /// It returns true if state change occurred, false otherwise.
  Future<bool> _fire(E eventId, {required dynamic arg}) async {
    _log.fine('START _internalFire');
    _cAssert(_activeStateId != null, 'Machine "$name" has not been started.');
    if (_activeStateId == null) return false;

    final transitionWithId = await _getTransitionByEvent(eventId, arg);
    return _executeTransition(
      transitionWithId: transitionWithId,
      eventId: eventId,
      arg: arg,
    );
  }

  Future<bool> _executeTransition({
    required _TransitionWithId<T, S>? transitionWithId,
    E? eventId,
    required dynamic arg,
  }) async {
    if (transitionWithId == null) return false;

    await transitionWithId.edge.onAction?.action.call(this, arg);

    // Check if machine was stopped in an asynchronous operation.
    // Null eventId means that method is invoked from machine start()
    // when EntryPoint is used. In this case machine is not yet started.
    if (eventId != null && _activeStateId == null) {
      _log.fine('Another asynchronous operation stopped our machine, '
          'we stop the transition.');
      return false;
    }

    if (transitionWithId.edge is Transition<S>) {
      final transition = transitionWithId.edge as Transition<S>;
      final targetState = states[transition.to];
      assert(
        targetState != null,
        'Target state is null identified by "${transition.to}"',
      );
      if (targetState == null) return false;

      // From here we know active state will change.

      if (targetState is FinalState) {
        // First we stop this state machine.
        await stop(arg: arg);
      } else if (targetState is ExitPoint) {
        // First we stop this state machine.
        await stop(arg: arg);
        // Then we notify region that this (child) machine exited due to
        // reaching an exitPoint.
        await notifyRegion?.call(
          ExitNotificationFromMachine(
            exitPointId: transition.to,
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
          stateId: transition.to,
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
    } else if (transitionWithId.edge is InternalTransition) {
      // Since it is an internal transition the active state does not change.
      return false;
    } else {
      assert(
        false,
        '${transitionWithId.edge} is neither Transition nor TransitionInt',
      );
      return false;
    }
  }

  S? get activeStateId => _activeStateId;

  /// Creates an array representing the states of this state machine and
  /// recursively all compounded state machines where an array means
  /// one state machine where 1st item is the state identifier and this
  /// array can contain zero or more sub state machines (regions) that
  /// are again defined as an array. By default it does not include stopped
  /// machines or machine names:
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
  /// When [includeMachineName] is set true the output will include the name of
  /// the corresponding machines. Note that when this option is used the result
  /// array will include strings instead of the state type:
  /// [
  ///   'RootMachine: StateID.s2',
  ///   [
  ///     'SubMachineA: SubStateID.s1',
  ///     ['SubSubMachineA: SubSubStateID.work'],
  ///     ['SubSubMachineB: SubSubStateID.work'],
  ///   ],
  ///   ...
  /// ]
  ///
  /// When [includeStopped] is set to true the output will include stopped
  /// machines as well:
  ///
  /// [
  ///   StateID.s2,
  ///   [
  ///     SubStateID.s1,
  ///     null
  ///     null,
  ///     [SubSubStateID.work],
  ///     [SubSubStateID.work],
  ///   ],
  ///   ...
  /// ]
  ///
  /// When both [includeStopped] and [includeMachineName] is set to true the
  /// output will include machine names and stopped machines where their stopped
  /// status is indicated by the '-' character:
  /// [
  ///   'RootMachine: StateID.s2',
  ///   [
  ///     'SubMachineA: SubStateID.s1',
  ///     'SubMachineB: -',
  ///     'SubMachineC: -',
  ///     ['SubSubMachineA: SubSubStateID.work'],
  ///     ['SubSubMachineB: SubSubStateID.work'],
  ///   ],
  ///   ...
  /// ]
  List<dynamic> getActiveStateRecursive({
    bool includeMachineName = false,
    bool includeStopped = false,
  }) {
    final result = <dynamic>[];
    if (_activeStateId == null && !includeStopped) return [];
    result.add(
      includeMachineName ? '$name: ${_activeStateId ?? '-'}' : _activeStateId,
    );
    for (final key in states.keys) {
      if (key == _activeStateId || includeStopped) {
        final state = states[key];
        if (state is State<E, T, S>) {
          final regions = <dynamic>[];
          for (final region in state.regions) {
            final r = region.machine.getActiveStateRecursive(
              includeMachineName: includeMachineName,
              includeStopped: includeStopped,
            );
            if (r.isNotEmpty) regions.add(r);
          }
          if (regions.isNotEmpty) result.addAll(regions);
        }
      }
    }
    return result;
  }

  Machine<S1, E1, T1> find<S1, E1, T1>(String name) {
    final machine = _findIt(name);
    if (machine is! Machine<S1, E1, T1>) {
      // We throw exception and not returning null to optimize for the usual
      // case when machine is found. This way user of find does not to worry
      // about null checking.
      throw HismaMachineNotFoundException(
        machine == null
            ? '$name machine is not found in ${this.name} hierarchy. '
            : '$name machine is not a Machine<$S1, $E1, $T1>.',
      );
    }
    return machine;
  }

  Machine<dynamic, dynamic, dynamic>? _findIt(String name) {
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
  Future<void> stop({dynamic arg}) async {
    _log.fine(() => '$name  stop, state:$activeStateId, arg:$arg');
    await _exitState(arg: arg);
    _activeStateId = null;
    _notifyMonitors();
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
      () =>
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

    _log.fine(() => 'fire arg: $arg');
    try {
      await state.onEntry?.action.call(this, arg);
    } on Exception catch (e) {
      _log.severe(() => 'Exception during onEntry: $e');
    }
    await _enterRegions(
      trigger: trigger,
      state: state,
      arg: arg,
      historyFlowDown: historyFlowDown,
    );

    _log.fine(() => '< $name  _enterState');
    _notifyMonitors();
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
      final entryPointId =
          getEntryPointId(region.entryConnectors, trigger)?.value;
      await region.machine.start(
        entryPointId: entryPointId,
        arg: historyFlowDown ? _HistoryFlowDown(arg) : arg,
      );
    }
  }

  /// Calculates which transition shall be used for the eventId parameter.
  Future<_TransitionWithId<T, S>?> _getTransitionByEvent(
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
    _cAssert(
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
  Future<_TransitionWithId<T, S>?> _selectTransition(
    List<T> transitionIds,
    dynamic arg,
  ) async {
    _TransitionWithId<T, S>? selectedTransitionWithId;
    for (final transitionId in transitionIds) {
      final transition = transitions[transitionId];
      assert(
        transition != null,
        'Transition could not be found by $transitionId',
      );
      if (transition == null) continue;

      final onSkip = transition.onSkip;
      final now = DateTime.now();
      if (transition.minInterval != null &&
          transition.lastTime != null &&
          now.difference(transition.lastTime!) < transition.minInterval!) {
        const message = 'Too little time passed since last transition.';
        if (onSkip != null) {
          _log.info(() => 'onSkip action at $transitionId: $message');
          await onSkip.action
              .call(this, OnSkipData(SkipSource.maxInterval, message, arg));
          continue;
        }
      }

      final guardAllows =
          await transition.guard?.condition.call(this, arg) ?? true;
      if (!guardAllows) {
        const message = 'Guard failed.';
        if (onSkip != null) {
          _log.info(() => 'onSkip action at $transitionId: $message');
          await onSkip.action
              .call(this, OnSkipData(SkipSource.guard, message, arg));
        }
        continue;
      }

      if (selectedTransitionWithId == null ||
          selectedTransitionWithId.edge.priority < transition.priority) {
        selectedTransitionWithId =
            _TransitionWithId(edge: transition, id: transitionId);
      }
    }

    selectedTransitionWithId?.edge.lastTime = DateTime.now();
    return selectedTransitionWithId;
  }

  Future<void> _processStateNotification(Message notification) async {
    assert(notification is ExitNotificationFromRegion);
    if (notification is ExitNotificationFromRegion<E>) {
      _log.info(
        () =>
            '$name _processNotification: Notification event=${notification.event} '
            'arg=${notification.arg}',
      );
      await fire(notification.event, arg: _Internal(notification.arg));
    }
  }

  Future<void> _processMachineNotification() async {
    _log.fine(() => '$name  call _processMachineNotification');
    _notifyMonitors();
    await parent?._processMachineNotification();
  }

  /// Machine operations can throw [AssertionError] exceptions as a result
  /// of failed assertions if we either
  /// * try starting an already started machine,
  /// * fire an event on an inactive machine or
  /// * firing an event that is not handled in the active state.
  ///
  /// We can enable or disable this behavior both at class level
  /// ([strict] class variable), impacting all subsequent
  /// Machine object creations or at object level in the
  /// constructor ([Machine.new]), impacting only the Machine object
  /// being created.
  static bool strict = true;
  late bool _strict;

  // ignore: avoid_positional_boolean_parameters
  void _cAssert(bool assertResult, String message) {
    if (!assertResult) {
      _log.fine(message);
      if (_strict) assert(assertResult, message);
    }
  }
}

/// Helper class to allow return both Transition and its ID from
/// the [_getTransitionByEvent] method.
class _TransitionWithId<T, S> {
  _TransitionWithId({
    required this.edge,
    required this.id,
  });

  Edge<S> edge;
  T id;
}

/// Helper class to hold both the monitor and the returned Future value of its
/// notifyCreation method. It is used in [_notifyMonitors] to send
/// state change notification only after the notifyCreation was completed.
class MonitorAndStatus {
  MonitorAndStatus({
    required this.monitor,
    required this.completed,
  });

  Monitor monitor;
  Future<void> completed;
}

/// Indicates if caller was internal. This saves us from having an only
/// internally used bool argument on the public API.
/// Internal fire invocations from Machine will use it
/// to avoid notifying parent state machines about a state change as
/// the original external fire will do that and this way we avoid sending
/// multiple notifications for parent machine about a state change.
class _Internal {
  _Internal(this.arg);
  dynamic arg;
}

/// Indicates that history flow down is needed. This saves us from having an
/// only internally used bool argument on the public API.
class _HistoryFlowDown {
  _HistoryFlowDown(this.arg);
  dynamic arg;
}

/// Returns the entry point id from the [entryConnectors] map that matches the
/// given [trigger] the most. If no match is found, null is returned.
/// Helper function for [Machine] and machine monitors.
MapEntry<Trigger<S, E, T>, dynamic>? getEntryPointId<S, E, T>(
  Map<Trigger<S, E, T>, dynamic>? entryConnectors,
  Trigger<S, E, T>? trigger,
) {
  MapEntry<Trigger<S, E, T>, dynamic>? selected;
  if (entryConnectors != null && trigger != null) {
    int compare(Trigger<S, E, T> t, Trigger<S, E, T> key) {
      if (key.source != null && key.source != t.source ||
          key.event != null && key.event != t.event ||
          key.transition != null && key.transition != t.transition) {
        return 0;
      }
      var result = 1;
      if (key.source == t.source) result++;
      if (key.event == t.event) result++;
      if (key.transition == t.transition) result++;
      return result;
    }

    var value = 0;
    for (final entry in entryConnectors.entries) {
      final res = compare(trigger, entry.key);
      if (res > value) {
        value = res;
        selected = entry;
      }
    }
  }
  return selected;
}
