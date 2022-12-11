import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../../../layers/machine/auth_machine.dart';

class SignedInScreen extends StatelessWidget {
  const SignedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signedInMachine =
        authMachine.find<SSiM, ESiM, TSiM>(signedInMachineName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SignedIn'),
        actions: [
          IconButton(
            onPressed: () {
              signedInMachine.fire(ESiM.profile);
            },
            icon: const Icon(Icons.account_circle),
          ),
          IconButton(
            onPressed: () {
              signedInMachine.fire(ESiM.intentSignOut);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
