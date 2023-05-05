import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/email_not_verified_error_dialog.dart';
import '../ui/email_not_verified_screen.dart';
import '../ui/signed_in_screen.dart';

final mainRouter = HismaRouterGenerator<SMM, Widget, EMM>(
  machine: authMachine.find<SMM, EMM, TMM>(mainMachineName),
  mapping: {
    SMM.check: NoUIChange(),
    SMM.emailNotVerified:
        MaterialPageCreator<SMM>(widget: const EmailNotVerifiedScreen()),
    SMM.error: PagelessCreator<void, EMM>(
      event: EMM.back,
      pagelessRouteManager: failedEmailVerifiedDialog(),
    ),
    SMM.app: MaterialPageCreator<SMM>(widget: const SignedInScreen()),
  },
);
