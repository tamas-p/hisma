import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> failedSignInDialog<E>({
  required BuildContext context,
  required bool rootNavigator,
  required Close<DateTime> close,
  required NavigationMachine<dynamic, dynamic, dynamic> machine,
  required E fireEvent,
  required dynamic fireArg,
}) =>
    createDialog(
      context: context,
      useRootNavigator: rootNavigator,
      message: 'Problem during login',
      title: '${authMachine.find<SLiM, ELiM, TLiM>(loginMachineName).data}',
    );

Future<void> failedSignInDialog2(BuildContext context) => showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final loginMachine =
            authMachine.find<SLiM, ELiM, TLiM>(loginMachineName);
        return AlertDialog(
          title: const Text('Problem during login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Err: ${loginMachine.data}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
