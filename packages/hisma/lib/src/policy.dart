class StateMachinePolicy {
  const StateMachinePolicy({
    this.mismatchEvents = const {ErrorBehavior.assertion},
  });

  // const StateMachinePolicy.defaults()
  //     : mismatchEvents = const {ErrorBehavior.assertion};

  final Set<ErrorBehavior> mismatchEvents;
}

extension StateMachinePolicyExt on StateMachinePolicy {
  StateMachinePolicy overrideWith(StateMachinePolicy? other) {
    return StateMachinePolicy(
      mismatchEvents: other?.mismatchEvents ?? mismatchEvents,
    );
  }
}

enum ErrorBehavior {
  /// Notice the error.
  notice,

  /// Raise an assertion.
  assertion,

  /// Throw an exception.
  exception,
}
