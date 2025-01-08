import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> profileLoadFailed({
  required BuildContext context,
  required bool rootNavigator,
  required Close<DateTime> close,
  required StateMachineWithChangeNotifier<dynamic, dynamic, dynamic> machine,
}) =>
    createDialog(
      context: context,
      useRootNavigator: rootNavigator,
      message: 'Problem during loading profile data.',
      title: '${authMachine.find<SPM, EPM, TPM>(profileMachineName)}',
    );
