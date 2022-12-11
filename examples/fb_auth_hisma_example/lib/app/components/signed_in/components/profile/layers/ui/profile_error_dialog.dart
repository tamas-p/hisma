import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> profileLoadFailed(BuildContext context) => authDialog(
      context,
      'Problem during loading profile data.',
      '${authMachine.find<SPM, EPM, TPM>(profileMachineName)}',
    );
