import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../../assistance.dart';

const String loggerName = 'main_assistance';
final log = getLogger(loggerName);

bool isEmailVerified() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  return user.emailVerified;
}

Future<void> sendEmailVerification() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await FirebaseAuth.instance.setLanguageCode('hu');
  await user.sendEmailVerification();
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
