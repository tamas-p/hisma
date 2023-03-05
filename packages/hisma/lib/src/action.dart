import 'state_machine.dart';

// TODO: shall we clone a Function??
typedef ActionFunction = Future<void> Function(
  StateMachine<dynamic, dynamic, dynamic> machine,
  dynamic arg,
);

/// Represents an action with its description.
class Action {
  Action({
    required this.description,
    required this.action,
  });

  final String description;
  ActionFunction action;
}
