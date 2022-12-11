import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../layers/machine/auth_machine.dart';

Future<void> signOutConfirmationDialog(BuildContext context) {
  final signedInMachine =
      authMachine.find<SSiM, ESiM, TSiM>(signedInMachineName);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Please confirm'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Are you sure to sign out?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              // Navigator.of(context).pop();
              signedInMachine.fire(ESiM.cancel);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              signedInMachine.fire(ESiM.initiateSignOut);
            },
          ),
        ],
      );
    },
  );
}
