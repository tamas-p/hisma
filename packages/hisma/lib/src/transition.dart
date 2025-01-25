import 'dart:async';

import 'action.dart';
import 'guard.dart';
import 'machine.dart';

abstract class Edge<S> {
  Edge({
    this.guard,
    this.priority = 0,
    this.onAction,
    this.onError,
    this.minInterval,
    this.lastTime,
  });
  final Guard? guard;
  final int priority;
  final Action? onAction;
  final OnErrorAction? onError;
  final Duration? minInterval;
  DateTime? lastTime;
}

class InternalTransition<S> extends Edge<S> {
  InternalTransition({
    Guard? guard,
    int priority = 0,
    required Action onAction,
    OnErrorAction? onError,
    Duration? minInterval,
  }) : super(
          guard: guard,
          priority: priority,
          onAction: onAction,
          onError: onError,
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
    OnErrorAction? onError,
    Duration? minInterval,
  }) : super(
          guard: guard,
          priority: priority,
          onAction: onAction,
          onError: onError,
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

enum OnErrorSource { guard, maxInterval }

class OnErrorData {
  OnErrorData({required this.source, required this.message, required this.arg});
  OnErrorSource source;
  String? message;
  dynamic arg;
}

typedef OnErrorActionFunction = FutureOr<void> Function(
  Machine<dynamic, dynamic, dynamic> machine,
  OnErrorData data,
);

class OnErrorAction {
  OnErrorAction({required this.description, required this.action});

  String description;
  OnErrorActionFunction action;
}
