import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> failedEmailVerifiedDialog(
  BuildContext context,
  bool rootNavigator,
  NavigatorState _,
  Close<DateTime> close,
  StateMachineWithChangeNotifier<dynamic, dynamic, dynamic> machine,
) =>
    createDialog(
      useRootNavigator: rootNavigator,
      context: context,
      message: 'Problem during sending verification email',
      title: '${authMachine.find<SMM, EMM, TMM>(mainMachineName).data}',
    );
