import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/profile_error_dialog.dart';
import '../ui/profile_screen.dart';

final profileRouter = HismaRouterGenerator<SPM, Widget, EPM>(
  machine: authMachine.find<SPM, EPM, TPM>(profileMachineName),
  creators: {
    SPM.profile: MaterialPageCreator<SPM>(widget: const ProfileScreen()),
    SPM.error: PagelessCreator<EPM, void>(
      show: profileLoadFailed,
      event: EPM.back,
    ),
  },
);
