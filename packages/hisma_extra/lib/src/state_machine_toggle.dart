import 'package:hisma/hisma.dart';

enum ToggleState {
  on,
  off,
}

enum ToggleEvent {
  toggle,
}

enum ToggleTransition {
  on,
  off,
}

/// PLaying around with the concept of state machine helpers to create
/// frequently used state machines with minimal lines of code.
class ToggleStateMachine
    extends Machine<ToggleState, ToggleEvent, ToggleTransition> {
  ToggleStateMachine({
    required super.name,
    ToggleState initialId = ToggleState.off,
  }) : super(
          events: ToggleEvent.values,
          initialStateId: initialId,
          states: {
            ToggleState.off: State(
              etm: {
                ToggleEvent.toggle: [ToggleTransition.on],
              },
            ),
            ToggleState.on: State(
              etm: {
                ToggleEvent.toggle: [ToggleTransition.off],
              },
            ),
          },
          transitions: {
            ToggleTransition.on: Transition(to: ToggleState.on),
            ToggleTransition.off: Transition(to: ToggleState.off),
          },
        );

  Future<void> toggle() => fire(ToggleEvent.toggle);
  bool get on => activeStateId! == ToggleState.on;
}
