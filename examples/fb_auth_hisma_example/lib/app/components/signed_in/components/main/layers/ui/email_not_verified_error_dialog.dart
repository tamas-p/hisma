import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> failedEmailVerifiedDialog2(
  BuildContext context, {
  void Function(BuildContext)? setContext,
}) =>
    authDialog(
      context,
      'Problem during sending verification email',
      '${authMachine.find<SMM, EMM, TMM>(mainMachineName).data}',
    );

DialogPagelessRouteManager<void> failedEmailVerifiedDialog() =>
    DialogPagelessRouteManager<void>(
      title: 'Problem during sending verification email',
      text: '${authMachine.find<SMM, EMM, TMM>(mainMachineName).data}',
    );
