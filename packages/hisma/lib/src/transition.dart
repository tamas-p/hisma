import 'dart:async';

import 'action.dart';
import 'guard.dart';
import 'machine.dart';

abstract class Edge<S> {
  Edge({
    this.guard,
    this.priority = 0,
    this.onAction,
    this.onSkip,
    this.minInterval,
    this.lastTime,
  });
  final Guard? guard;
  final int priority;
  final Action? onAction;
  final OnSkipAction? onSkip;
  final Duration? minInterval;
  DateTime? lastTime;
}

class InternalTransition<S> extends Edge<S> {
  InternalTransition({
    Guard? guard,
    int priority = 0,
    required Action onAction,
    OnSkipAction? onSkip,
    Duration? minInterval,
  }) : super(
          guard: guard,
          priority: priority,
          onAction: onAction,
          onSkip: onSkip,
          minInterval: minInterval,
        );
}

/// Represents a transition including the corresponding guard and priority
/// to this target and the action that happens at the transition.
/// [S] State identifier type.
class Transition<S> extends Edge<S> {
  /// Creates the object that represents a transition.
  /// * [to] Target state of the transition.
  /// * [guard] The guard function that only returns true if transition allowed.
  /// * [priority] Priority of the transition as integer. Higher value means
  /// higher priority. Default value is 0. It is used to compare transitions
  /// when multiple of them is defined for a triggering event (potentially
  /// with different guards as it is the reason allowing multiple potential
  /// transitions for the same triggering event).
  /// * [onAction] Function invoked when transition occurs.
  Transition({
    required this.to,
    Guard? guard,
    int priority = 0,
    Action? onAction,
    OnSkipAction? onSkip,
    Duration? minInterval,
  }) : super(
          guard: guard,
          priority: priority,
          onAction: onAction,
          onSkip: onSkip,
          minInterval: minInterval,
        );

  final S to;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transition<S> &&
        other.to == to &&
        other.guard == guard &&
        other.priority == priority &&
        other.onAction == onAction;
  }

  @override
  int get hashCode {
    return to.hashCode ^ guard.hashCode ^ priority.hashCode ^ onAction.hashCode;
  }
}

/// In case of a transition is skipped, this data is also passed to the onSkip
/// action indicating what was the cause of the skip.
enum SkipSource { guard, maxInterval }

class OnSkipData {
  OnSkipData(this.source, this.message, this.arg);
  SkipSource source;
  String? message;
  dynamic arg;
}

typedef OnSkipActionFunction = FutureOr<void> Function(
  Machine<dynamic, dynamic, dynamic> machine,
  OnSkipData data,
);

class OnSkipAction {
  OnSkipAction({required this.description, required this.action});

  String description;
  OnSkipActionFunction action;
}
