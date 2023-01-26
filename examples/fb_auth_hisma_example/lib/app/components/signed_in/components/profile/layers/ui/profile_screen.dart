import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';

import '../../../../../../layers/machine/auth_machine.dart';

const String _na = 'N/A';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileMachine = authMachine.find<SPM, EPM, TPM>(profileMachineName);
  final _load =
      authMachine.find<SPM, EPM, TPM>(profileMachineName).fire(EPM.load);
  String displayName = '';

  Row _createRow(String name, String? id) {
    return Row(
      children: [
        Text('$name: '),
        Text(id ?? _na),
      ],
    );
  }

  Row _createEditableRow(
    String name,
    String? id, {
    void Function(String text)? exec,
  }) {
    exec?.call(id ?? _na);
    return Row(
      children: [
        Text('$name: '),
        Flexible(
          child: SizedBox(
            height: 35.0,
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController()..text = id ?? _na,
              onChanged: exec,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fb = FutureBuilder<void>(
      future: _load,
      builder: (context, snapshot) {
        final list = <Widget>[];
        if (snapshot.connectionState == ConnectionState.done) {
          if (profileMachine.data is Profile2) {
            // list.add(
            //   _createRow(
            //     'isVerified:',
            //     '${FirebaseAuth.instance.currentUser?.emailVerified}',
            //   ),
            // );
            list.add(const Divider(color: Colors.blue));
            final profile = profileMachine.data as Profile2;
            final p = profile.profile;

            list.add(_createRow('uid', p[PE.uid]));
            // list.add(_createRow('tenantId', p[PE.tenantId]));
            list.add(
              _createEditableRow(
                'displayName',
                p[PE.displayName],
                exec: (text) {
                  displayName = text;
                },
              ),
            );
            list.add(_createRow('email', p[PE.email]));
            list.add(_createRow('phoneNumber', p[PE.phoneNumber]));
            list.add(_createRow('photoURL', p[PE.photoURL]));
            list.add(const Divider(color: Colors.green));
            for (final pp in profile.providerProfiles) {
              list.add(_createRow('providerId', pp[PE.providerId]));
              list.add(_createRow('uid', pp[PE.uid]));
              list.add(_createRow('displayName', pp[PE.displayName]));
              list.add(_createRow('email', pp[PE.email]));
              list.add(_createRow('phoneNumber', pp[PE.phoneNumber]));
              list.add(_createRow('photoURL', pp[PE.photoURL]));
              list.add(const Divider());
            }
            list.add(
              ElevatedButton(
                onPressed: () {},
                child: const Text('Update'),
              ),
            );
          }
          if (profileMachine.data is Profile) {
            // list.add(
            //   _createRow(
            //     'isVerified:',
            //     '${FirebaseAuth.instance.currentUser?.emailVerified}',
            //   ),
            // );
            list.add(const Divider(color: Colors.blue));
            final p = profileMachine.data as Profile;

            list.add(_createRow('uid', p.uid));
            // list.add(_createRow('tenantId', p[PE.tenantId]));
            list.add(
              _createEditableRow(
                'displayName',
                p.displayName,
                exec: (text) {
                  displayName = text;
                },
              ),
            );
            list.add(_createRow('email', p.email));
            list.add(_createRow('phoneNumber', p.phoneNumber));
            list.add(_createRow('photoURL', p.photoURL));
            list.add(const Divider(color: Colors.green));
            for (final pp in p.providerProfiles ?? <ProviderProfile>[]) {
              list.add(_createRow('providerId', pp.providerId));
              list.add(_createRow('uid', pp.uid));
              list.add(_createRow('displayName', pp.displayName));
              list.add(_createRow('email', pp.email));
              list.add(_createRow('phoneNumber', pp.phoneNumber));
              list.add(_createRow('photoURL', pp.photoURL));
              list.add(const Divider());
            }
            list.add(
              ElevatedButton(
                onPressed: () {
                  profileMachine.fire(EPM.update, arg: displayName);
                },
                child: const Text('Update'),
              ),
            );
          } else {
            list.add(const Text('Failed loading profile'));
            profileMachine.fire(
              EPM.error,
              arg: 'Profile could not be loaded.',
            );
          }
        } else if (snapshot.hasError) {
          list.addAll(<Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            ),
          ]);
        } else {
          list.addAll(const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            ),
          ]);
        }

        return Column(
          children: [
            SelectionArea(child: Column(children: list)),
          ],
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: BackButton(
          onPressed: () => authMachine
              .find<SSiM, ESiM, TSiM>(signedInMachineName)
              .fire(ESiM.back),
        ),
      ),
      body: fb,
    );
  }
}
