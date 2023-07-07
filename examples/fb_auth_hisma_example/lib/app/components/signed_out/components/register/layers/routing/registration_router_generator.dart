import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/registration_screen.dart';

final registrationRouterGenerator = HismaRouterGenerator<SRM, ERM>(
  machine: authMachine.find<SRM, ERM, TRM>(registerMachineName),
  mapping: {
    SRM.registration:
        MaterialPageCreator<void, SRM, ERM>(widget: const RegistrationScreen()),
    SRM.failed: DialogCreator<void, ERM>(
      useRootNavigator: true,
      event: ERM.ok,
      show: (dc, context) => showDialog(
        useRootNavigator: dc.useRootNavigator,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Problem during registration'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Err: ${authMachine.find<SRM, ERM, TRM>(registerMachineName).data}',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  dc.close();
                },
              ),
            ],
          );
        },
      ),
    ),
  },
);
