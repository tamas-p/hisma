import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/email_not_verified_error_dialog.dart';
import '../ui/email_not_verified_screen.dart';
import '../ui/signed_in_screen.dart';

final mainRouter = HismaRouterGenerator<SMM, EMM>(
  machine: authMachine.find<SMM, EMM, TMM>(mainMachineName),
  mapping: {
    SMM.check: NoUIChange(),
    SMM.emailNotVerified: MaterialPageCreator<void, SMM, EMM>(
      widget: const EmailNotVerifiedScreen(),
    ),
    SMM.error: DialogCreator<void, EMM>(
      event: EMM.back,
      show: failedEmailVerifiedDialog,
      useRootNavigator: true,
    ),
    SMM.app:
        MaterialPageCreator<void, SMM, EMM>(widget: const SignedInScreen()),
  },
);
