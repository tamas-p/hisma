import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/failed_signin_dialog.dart';
import '../ui/login_screen.dart';

final loginRouter = HismaRouterGenerator<SLiM, ELiM>(
  machine: authMachine.find<SLiM, ELiM, TLiM>(loginMachineName),
  mapping: {
    SLiM.login:
        MaterialPageCreator<void, SLiM, ELiM>(widget: const LoginScreen()),
    SLiM.failedSignIn: DialogCreator<void, ELiM>(
      event: ELiM.ok,
      show: failedSignInDialog,
      useRootNavigator: true,
    ),
  },
);
