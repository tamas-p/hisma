import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../../../layers/machine/auth_machine.dart';

class EmailNotVerifiedScreen extends StatefulWidget {
  const EmailNotVerifiedScreen({super.key});

  @override
  State<EmailNotVerifiedScreen> createState() => _EmailNotVerifiedScreenState();
}

class _EmailNotVerifiedScreenState extends State<EmailNotVerifiedScreen> {
  bool isVerified = false;

  @override
  Widget build(BuildContext context) {
    final mainMachine = authMachine.find<SMM, EMM, TMM>(mainMachineName);
    final signedInMachine =
        authMachine.find<SSiM, ESiM, TSiM>(signedInMachineName);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EmailNotVerifiedScreen'),
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
      body: Column(
        children: [
          Text(
            'Your email is not verified ($isVerified).\n'
            'Please verify and login again.',
          ),
          ElevatedButton(
            onPressed: () async {
              await mainMachine.fire(EMM.resendEmail);
            },
            child: const Text('Resend verification email'),
          ),
          ElevatedButton(
            onPressed: () async {
              await mainMachine.fire(EMM.reload);
              isVerified = mainMachine.data as bool;
              if (isVerified) {
                await mainMachine.fire(EMM.emailVerified);
              }
              setState(() {});
            },
            child: const Text('Check verification'),
          ),
        ],
      ),
    );
  }
}
