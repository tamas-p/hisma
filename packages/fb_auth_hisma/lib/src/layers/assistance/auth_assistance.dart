import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart' as logging;

const String loggerName = 'auth_assistance';
final log = logging.Logger(loggerName);

class AuthenticationException implements Exception {
  AuthenticationException({
    required this.message,
    required this.errorCode,
  });
  final String message;
  final ErrorCode errorCode;
}

enum ErrorCode {
  generic,
  emailAlreadyInUse,
  invalidEmail,
  operationNotAllowed,
  weakPassword,
  requiresRecentLogin,
}

final firebaseErrorCodes = {
  'email-already-in-use': ErrorCode.emailAlreadyInUse,
  'invalid-email': ErrorCode.invalidEmail,
  'operation-not-allowed': ErrorCode.operationNotAllowed,
  'weak-password': ErrorCode.weakPassword,
  'requires-recent-login': ErrorCode.requiresRecentLogin,
};

bool refresh() {
  final user = FirebaseAuth.instance.currentUser;
  log.info('user=$user');
  if (user == null) {
    return false;
  }

  return user.emailVerified;
}

Future<bool> reload() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return false;
  }

  try {
    log.fine('BEFORE user=$user');
    // We need both reload and .currentUser due toa FirebaseAuth bug:
    // https://github.com/flutter/flutter/issues/20390
    await user.reload();
    final user2 = FirebaseAuth.instance.currentUser;
    log.fine('AFTER user=$user');
    if (user2 == null) {
      return false;
    }
    return user2.emailVerified;
  } on FirebaseAuthException catch (e) {
    log.severe('Reload error: $e');
    rethrow;
  }
}
