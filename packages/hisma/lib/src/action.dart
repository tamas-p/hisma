import 'dart:async';

import 'machine.dart';

// TODO: shall we clone a Function??
typedef ActionFunction = FutureOr<void> Function(
  Machine<dynamic, dynamic, dynamic> machine,
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
