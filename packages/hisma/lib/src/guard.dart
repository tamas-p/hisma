class Guard {
  Guard({
    required this.condition,
    required this.description,
  });

  final bool Function() condition;
  final String description;

  Guard copyWith({
    bool Function()? condition,
    String? description,
  }) {
    return Guard(
      condition: condition ?? this.condition,
      description: description ?? this.description,
    );
  }
}
