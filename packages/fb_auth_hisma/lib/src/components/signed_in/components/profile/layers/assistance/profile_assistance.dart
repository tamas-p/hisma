import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../../assistance.dart';
import '../../../../../../layers/assistance/auth_assistance.dart';
import 'profile.dart';

class ProfileAssistance {
  static final log = getLogger('$ProfileAssistance');

  static ProfileMap _getP(UserInfo userInfo) => {
        PE.providerId: userInfo.providerId,
        if (userInfo.uid != null) PE.uid: userInfo.uid!,
        if (userInfo.displayName != null) PE.displayName: userInfo.displayName!,
        if (userInfo.email != null) PE.email: userInfo.email!,
        if (userInfo.photoURL != null) PE.email: userInfo.photoURL!,
        if (userInfo.phoneNumber != null) PE.phoneNumber: userInfo.phoneNumber!,
      };

  static Profile2? getProfile2() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      user.reload();
    } on FirebaseAuthException catch (e) {
      log.severe('Reload error: $e');
      rethrow;
    }

    return Profile2(
      profile: {
        PE.uid: user.uid,
        if (user.displayName != null) PE.displayName: user.displayName!,
        if (user.email != null) PE.email: user.email!,
        if (user.photoURL != null) PE.email: user.photoURL!,
        if (user.phoneNumber != null) PE.phoneNumber: user.phoneNumber!,
      },
      providerProfiles: user.providerData.map((ui) => _getP(ui)).toList(),
    );
  }

  static Profile? getProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final profile = Profile(
      providerProfiles: user.providerData
          .map(
            (e) => ProviderProfile(
              providerId: e.providerId,
              displayName: e.displayName,
              email: e.email,
              phoneNumber: e.phoneNumber,
              photoURL: e.photoURL,
              uid: e.uid,
            ),
          )
          .toList(),
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoURL: user.photoURL,
      tenantId: user.tenantId,
    );

    log.fine(user.displayName);
    log.fine(user.email);
    log.fine(user.uid);
    log.fine(user.tenantId);
    for (final providerProfile in user.providerData) {
      log.fine('-----');
      // ID of the provider (google.com, apple.com, etc.)
      log.fine(providerProfile.providerId);

      // UID specific to the provider
      log.fine(providerProfile.uid);

      // Name, email address, and profile photo URL
      log.fine(providerProfile.displayName);
      log.fine(providerProfile.email);
      log.fine(providerProfile.photoURL);
    }

    return profile;
  }

  static Future<void> updateProfile(Profile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // TODO Error handling.

    if (profile.displayName != null) {
      await user.updateDisplayName(profile.displayName);
    }

    // if (profile.email != null) {
    //   // await user.updateEmail(profile.email!);
    //   await user.verifyBeforeUpdateEmail(profile.email!);
    // }

    // await user.updatePassword('newPassword');
    // await user.updatePhoneNumber(
    //   PhoneAuthProvider.credential(
    //     verificationId: 'verificationId',
    //     smsCode: 'smsCode',
    //   ),
    // );
    // await user.updatePhotoURL('photoURL');
  }
}

Future<void>? convertException(Future<void> Function(String)? f, String arg) {
  try {
    return f?.call(arg);
  } on FirebaseAuthException catch (e) {
    throw AuthenticationException(
      errorCode: firebaseErrorCodes[e.code] ?? ErrorCode.generic,
      message: e.code,
    );
  }
}

class ProfileUpdate {
  static Future<void>? updateEmail(String email) => convertException(
        FirebaseAuth.instance.currentUser?.updateEmail,
        email,
      );

  static Future<void>? updatePassword(String password) => convertException(
        FirebaseAuth.instance.currentUser?.updatePassword,
        password,
      );

  static Future<void>? updateDisplayName(String displayName) =>
      FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
  static Future<void>? verifyBeforeUpdateEmail(String email) =>
      FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
  // static Future<void>? updatePhoneNumber(String email) {
  //   return FirebaseAuth.instance.currentUser?.updatePhoneNumber(email);
  // }
  static Future<void>? updatePhotoURL(String photoURL) =>
      FirebaseAuth.instance.currentUser?.updatePhotoURL(photoURL);
}
