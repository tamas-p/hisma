import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> failedEmailVerifiedDialog(BuildContext context) => authDialog(
      context,
      'Problem during sending verification email',
      '${authMachine.find<SMM, EMM, TMM>(mainMachineName).data}',
    );
