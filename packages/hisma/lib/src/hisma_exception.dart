class HismaException implements Exception {
  HismaException(this.message);
  final String message;

  @override
  String toString() => message;
}

class HismaMachineNotFoundException extends HismaException {
  HismaMachineNotFoundException(String message) : super(message);
}
