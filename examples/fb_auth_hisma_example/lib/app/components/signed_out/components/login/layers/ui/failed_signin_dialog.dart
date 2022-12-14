import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../../../../../../layers/ui/util/ui_util.dart';

Future<void> failedSignInDialog(BuildContext context) => authDialog(
      context,
      'Problem during login',
      '${authMachine.find<SLiM, ELiM, TLiM>(loginMachineName).data}',
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
