import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../../../../assistance.dart';
import '../../../../../../layers/machine/auth_machine.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  static final log = getLogger('$_RegistrationScreenState');

  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            authMachine.find<SRM, ERM, TRM>(registerMachineName).fire(ERM.back);
          },
        ),
        title: const Text('Registration'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'email',
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              setState(() {
                username = value;
              });
            },
          ),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              log.fine('User: $username, Password: $password');
              final uCredentials = Credentials(
                email: username,
                password: password,
              );
              final registerMachine =
                  authMachine.find<SRM, ERM, TRM>(registerMachineName);
              await registerMachine.fire(ERM.register, data: uCredentials);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
