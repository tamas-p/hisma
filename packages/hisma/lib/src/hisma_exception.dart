class HismaException implements Exception {
  HismaException({required this.reason});
  String reason;
}

class HismaIntervalException extends HismaException {
  HismaIntervalException({required String reason}) : super(reason: reason);
}
