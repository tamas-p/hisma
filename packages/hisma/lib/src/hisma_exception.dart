class HismaException implements Exception {
  HismaException(this.message);
  final String message;

  @override
  String toString() => message;
}

class HismaIntervalException extends HismaException {
  HismaIntervalException(String message) : super(message);
}

class HismaGuardException extends HismaException {
  HismaGuardException(String message) : super(message);
}

class HismaMachineNotFoundException extends HismaException {
  HismaMachineNotFoundException(String message) : super(message);
}
