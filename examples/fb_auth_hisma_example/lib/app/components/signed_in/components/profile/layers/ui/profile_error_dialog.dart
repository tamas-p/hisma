import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

class PresentProfileErrorDialog implements Presenter<void> {
  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<DateTime> close,
    required dynamic arg,
  }) =>
      createDialog(
        context: context,
        useRootNavigator: rootNavigator,
        message: 'Problem during loading profile data.',
        title: '${authMachine.find<SPM, EPM, TPM>(profileMachineName)}',
      );
}
