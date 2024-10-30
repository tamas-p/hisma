import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> failedEmailVerifiedDialog(
  OldDialogCreator<EMM, void> dc,
  BuildContext context,
) =>
    createDialog(
      useRootNavigator: dc.useRootNavigator,
      dc: dc,
      context: context,
      message: 'Problem during sending verification email',
      title: '${authMachine.find<SMM, EMM, TMM>(mainMachineName).data}',
    );
