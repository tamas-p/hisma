import '../hisma.dart';

typedef GuardFunction = Future<bool> Function(
  StateMachine<dynamic, dynamic, dynamic> machine,
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
