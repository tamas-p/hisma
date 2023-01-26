import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../../../../assistance.dart';
import '../../../../../../layers/machine/auth_machine.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final log = getLogger('$_LoginScreenState');
  String username = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoginScreen'),
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
              log.fine('User: $username, Password: ******');
              final uCredentials = Credentials(
                email: username,
                password: password,
              );
              final loginMachine =
                  authMachine.find<SLiM, ELiM, TLiM>(loginMachineName);
              await loginMachine.fire(ELiM.emailSignIn, arg: uCredentials);
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () async {
              final signedOutMachine =
                  authMachine.find<SSoM, ESoM, TSoM>(signedOutMachineName);
              await signedOutMachine.fire(ESoM.register);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
