import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../layers/machine/auth_machine.dart';

class PresentSignOutConfirmationDialog implements Presenter<void> {
  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<void> close,
    required dynamic fireArg,
  }) {
    final signedInMachine =
        authMachine.find<SSiM, ESiM, TSiM>(signedInMachineName);
    return showDialog(
      useRootNavigator: rootNavigator,
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
}
