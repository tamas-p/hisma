import 'action.dart';
import 'guard.dart';

/// Represents a transition including the corresponding guard and priority
/// to this target and the action that happens at the transition.
/// [S] State identifier type.
class Transition<S> {
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
    this.guard,
    this.priority = 0,
    this.onAction,
    this.minInterval,
  });

  final S to;
  final Guard? guard;
  final int priority;
  final Action? onAction;
  final Duration? minInterval;
  DateTime? lastTime;

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
