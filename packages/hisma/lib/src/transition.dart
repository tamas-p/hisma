import 'action.dart';
import 'guard.dart';
import 'state_machine.dart';

abstract class Edge {
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

class InternalTransition extends Edge {
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
class Transition<S> extends Edge {
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

  Transition<S> copyWith({
    S? to,
    Guard? guard,
    int? priority,
    Action? onAction,
    Duration? minInterval,
  }) {
    return Transition<S>(
      to: to ?? this.to,
      guard: guard ?? this.guard,
      priority: priority ?? this.priority,
      onAction: onAction ?? this.onAction,
      minInterval: minInterval ?? this.minInterval,
    );
  }
}

enum OnErrorSource { guard, maxInterval }

class OnErrorData {
  OnErrorData({required this.source, required this.message, required this.arg});
  OnErrorSource source;
  String? message;
  dynamic arg;
}

typedef OnErrorActionFunction = Future<void> Function(
  StateMachine<dynamic, dynamic, dynamic> machine,
  OnErrorData data,
);

class OnErrorAction {
  OnErrorAction({required this.description, required this.action});

  factory OnErrorAction.noAction() => OnErrorAction(
        description: 'nope',
        action: (_, __) async {},
      );

  String description;
  OnErrorActionFunction action;
}
