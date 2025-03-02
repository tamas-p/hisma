import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/profile_error_dialog.dart';
import '../ui/profile_screen.dart';

final profileRouter = HismaRouterGenerator<SPM, EPM>(
  machine: authMachine.find<SPM, EPM, TPM>(profileMachineName),
  mapping: {
    SPM.profile: MaterialPageCreator<EPM, void>(widget: const ProfileScreen()),
    SPM.error: PagelessCreator<EPM, void>(
      present: profileLoadFailed,
      rootNavigator: true,
      event: EPM.back,
    ),
  },
);
