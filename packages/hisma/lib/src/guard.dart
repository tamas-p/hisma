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

  Guard copyWith({
    GuardFunction? condition,
    String? description,
  }) {
    return Guard(
      condition: condition ?? this.condition,
      description: description ?? this.description,
    );
  }
}
