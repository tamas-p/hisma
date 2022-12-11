import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../../assistance.dart';
import '../../../../../../layers/assistance/auth_assistance.dart';
import '../../../login/layers/assistance/login_assistance.dart';

const String loggerName = 'registration_assistance';
final log = getLogger(loggerName);

Future<void> createUserWithEmailAndPassword(Credentials uCredentials) async {
  try {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: uCredentials.email,
      password: uCredentials.password,
    );

    await FirebaseAuth.instance.setLanguageCode('hu');
    await userCredential.user?.sendEmailVerification();
    log.info('Registration successful with $userCredential.');
  } on FirebaseAuthException catch (e) {
    log.severe('Auth error: ${e.code}');
    throw AuthenticationException(
      errorCode: firebaseErrorCodes[e.code] ?? ErrorCode.generic,
      message: e.code,
    );
  }
}
