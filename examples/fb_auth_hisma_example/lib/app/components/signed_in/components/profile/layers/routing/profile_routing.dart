import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/profile_error_dialog.dart';
import '../ui/profile_screen.dart';

final profileRouter = HismaRouterGenerator<SPM, EPM>(
  machine: authMachine.find<SPM, EPM, TPM>(profileMachineName),
  mapping: {
    SPM.profile:
        MaterialPageCreator<void, SPM, EPM>(widget: const ProfileScreen()),
    SPM.error: DialogCreator<void, EPM>(
      useRootNavigator: true,
      show: profileLoadFailed,
      event: EPM.back,
    ),
  },
);
