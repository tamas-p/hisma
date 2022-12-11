import 'package:firebase_auth/firebase_auth.dart';

import '../../../../assistance.dart';

const String loggerName = 'sign_out_assistance';
final log = getLogger(loggerName);

Future<void> signOut() async {
  log.info('Signing out...');
  try {
    await FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (e) {
    log.severe('Sign out error: $e');
    rethrow;
  }
}
