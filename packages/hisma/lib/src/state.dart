// Represents a state
import 'action.dart';
import 'notification.dart';
import 'region.dart';
import 'state_machine.dart';

typedef EventTransitionMap<E, T> = Map<E, List<T>>;
typedef RegionList<S, E, T> = List<Region<S, E, T, dynamic>>;
// typedef ActionFunction<S> = void Function(S stateId);

/*
@startuml
title "hisma State Classes"
BaseState <|-- RegularState
RegularState <|-- State
BaseState <|-- PseudoState
PseudoState <|-- BaseEntryPoint
PseudoState <|-- ExitPoint
PseudoState <|-- FinalState
BaseEntryPoint <|-- EntryPoint
BaseEntryPoint <|-- HistoryEntryPoint
@enduml
*/

// TODO: Why not S,E,T just like for StateMachine?
/// Base class for all states.
abstract class BaseState<E, T, S> {
  // TODO: seems useful, but still not used in hisma examples. Do we need this?
  late final StateMachine<S, E, T> machine;
}

/// Base class for regular states (vs pseudo states).
abstract class RegularState<E, T, S> extends BaseState<E, T, S> {}

/// Represents a state in the state machine.
class State<E, T, S> extends RegularState<E, T, S> {
  /// Creates the state object. It can be a compound state if child
  /// state machines are provided as regions.
  /// * [etm] Event to Transition map.
  /// * [regions] List of child state machines (sub-machines) with their
  /// entries and exits defined.
  /// * [onEntry] Function that is executed when this state becomes active.
  /// * [onExit] Function that is executed when this state becomes inactive.
  State({
    EventTransitionMap<E, T>? etm,
    RegionList<S, E, T>? regions,
    this.onEntry,
    // this.doActivity,
    this.onExit,
    // TODO: Only initialized here to create a MUTABLE State:
  })  : regions = regions ?? [],
        etm = etm ?? {} {
    // Passes callback got from parent state machine to all regions to
    // be used when a child state machine exits.
    for (final region in this.regions) {
      region.notifyState = _processRegionNotification;
      // region.notifyStateChange = notifyStateChange;
      // region.parentId = parentId;
    }
  }

  final EventTransitionMap<E, T> etm;
  RegionList<S, E, T> regions;
  final Action? onEntry;
  // final Action? doActivity;
  final Action? onExit;

  /// Notifies parent state machine about an event to be processed as
  /// a result of child machine exit.
  /// TODO: it was final before and late.
  Future<void> Function(Message)? notifyMachine;

  /// Processes event notification from a [Region]. It's only purpose
  /// is to pass it upwards to the enclosing parent state machine.
  Future<void> _processRegionNotification(Message notification) async {
    // for (final region in regions ?? []) {
    //   if (region.machine.activeStateId == null) return;
    //   await region.machine.stop();
    // }

    await notifyMachine?.call(notification);
  }

  // TODO: This is only added as POC to test mutable StateMachine concept.
  void addRegion<SS>(Region<S, E, T, SS> region) {
    region.notifyState = _processRegionNotification;
    regions.add(region);

    // final nameMessage = GetName();
    // notifyMachine?.call(nameMessage);
    // region.machine.parentName = nameMessage.name;
    region.machine.notifyMonitors();
    notifyMachine?.call(StateChangeNotification());
  }

  State<E, T, S> copyWith({
    EventTransitionMap<E, T>? etm,
    RegionList<S, E, T>? regions,
    Action? onEntry,
    Action? doActivity,
    Action? onExit,
  }) {
    return State<E, T, S>(
      etm: etm ?? EventTransitionMap.from(this.etm),
      regions:
          regions ?? this.regions.map((region) => region.copyWith()).toList(),
      onEntry: onEntry ?? this.onEntry,
      // doActivity: doActivity ?? this.doActivity,
      onExit: onExit ?? this.onExit,
    );
  }
}

//------------------------------------------------------------------------------

/// Base class for all pseudo states (vs regular states).
abstract class PseudoState<E, T, S> extends BaseState<E, T, S> {}

/// Base class for all entry points.
abstract class BaseEntryPoint<E, T, S> extends PseudoState<E, T, S> {}

/// Enclosing region in parent machine will map a [Trigger] to
/// the EntryPoint in the child machine.
class EntryPoint<E, T, S> extends BaseEntryPoint<E, T, S> {
  EntryPoint(this.transitionIds);
  final List<T> transitionIds;
}

/// Enclosing region in the parent machine will map this ExitPoint
/// into an event in the parent machine.
class ExitPoint<E, T, S> extends PseudoState<E, T, S> {}

enum HistoryLevel { shallow, deep }

class HistoryEntryPoint<S, E, T> extends BaseEntryPoint<S, E, T> {
  HistoryEntryPoint(this.level);
  final HistoryLevel level;
}

class FinalState<S, E, T> extends PseudoState<S, E, T> {}
