// ignore_for_file: directives_ordering

/// Provides state machines for Firebase authentication.
///
/// [Hisma](../hisma/) state machines for user management with
/// [Firebase Authentication](https://firebase.google.com/docs/auth).
library fb_auth_hisma;

export 'src/layers/machine/auth_machine.dart';
export 'src/components/signed_in/layers/machine/signed_in_machine.dart';
export 'src/components/signed_in/components/main/layers/machine/main_machine.dart';
export 'src/components/signed_in/components/profile/layers/machine/profile_machine.dart';
export 'src/components/signed_out/layers/machines/signed_out_machine.dart';
export 'src/components/signed_in/components/profile/layers/assistance/profile.dart';
export 'src/components/signed_out/components/login/layers/machines/login_machine.dart';
export 'src/components/signed_out/components/login/layers/assistance/login_assistance.dart';
export 'src/components/signed_out/components/register/layers/machine/register_machine.dart';
