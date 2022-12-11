import 'state_machine.dart';

// TODO: shall we clone a Function??
typedef ActionFunction = Future<void> Function(
  StateMachine<dynamic, dynamic, dynamic> machine,
  dynamic parameter,
);

/// Represents an action with its description.
class Action {
  Action({
    required this.description,
    required this.action,
  });

  final String description;
  ActionFunction action;

  Action copyWith({
    String? description,
    ActionFunction? action,
  }) {
    return Action(
      description: description ?? this.description,
      action: action ?? this.action,
    );
  }
}
