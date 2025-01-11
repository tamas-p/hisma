import 'dart:async';

import '../hisma.dart';

typedef GuardFunction = FutureOr<bool> Function(
  Machine<dynamic, dynamic, dynamic> machine,
  dynamic arg,
);

class Guard {
  Guard({
    required this.condition,
    required this.description,
  });

  final GuardFunction condition;
  final String description;
}
