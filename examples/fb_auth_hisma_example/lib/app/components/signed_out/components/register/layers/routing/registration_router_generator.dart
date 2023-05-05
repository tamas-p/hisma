import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../layers/machine/auth_machine.dart';
import '../ui/registration_screen.dart';

final registrationRouterGenerator = HismaRouterGenerator<SRM, Widget, ERM>(
  machine: authMachine.find<SRM, ERM, TRM>(registerMachineName),
  mapping: {
    SRM.registration:
        MaterialPageCreator<SRM>(widget: const RegistrationScreen()),
    SRM.failed: PagelessCreator<ERM, void>(
      event: ERM.ok,
      show: (
        context, {
        void Function(BuildContext)? setContext,
      }) =>
          showDialog(
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
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      ),
    ),
  },
);
