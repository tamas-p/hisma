// Represents a state
import 'action.dart';
import 'machine.dart';
import 'notification.dart';
import 'region.dart';

typedef EventTransitionMap<E, T> = Map<E, List<T>>;
typedef RegionList<S, E, T> = List<Region<S, E, T, dynamic>>;
// typedef ActionFunction<S> = void Function(S stateId);

/*
@startuml
title "hisma State Classes"
abstract class BaseState<E, T, S>
abstract class RegularState<E, T, S>
BaseState <|-- RegularState
RegularState <|-- State
class State<E, T, S>
abstract class PseudoState<E, T, S>
abstract class BaseEntryPoint<E, T, S>
class EntryPoint<E, T, S>
class ExitPoint<E, T, S>
class HistoryEntryPoint<E, T, S>
class FinalState<E, T, S>

BaseState <|-- PseudoState
PseudoState <|-- BaseEntryPoint
PseudoState <|-- ExitPoint
PseudoState <|-- FinalState
BaseEntryPoint <|-- EntryPoint
BaseEntryPoint <|-- HistoryEntryPoint
@enduml
*/

// TODO: Why not S,E,T just like for Machine?
/// Base class for all states.
abstract class BaseState<E, T, S> {
  // TODO: seems useful, but still not used in hisma examples.
  // Do we need this?
  // It is used in createButtonsFromStates()
  late final Machine<S, E, T> machine;
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
  Future<void> Function(Message)? notifyMachine;

  /// Processes event notification from a [Region]. It's only purpose
  /// is to pass it upwards to the enclosing parent state machine.
  Future<void> _processRegionNotification(Message notification) async {
    await notifyMachine?.call(notification);
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

class HistoryEntryPoint<E, T, S> extends BaseEntryPoint<E, T, S> {
  HistoryEntryPoint(this.level);
  final HistoryLevel level;
}

class FinalState<E, T, S> extends PseudoState<E, T, S> {}
