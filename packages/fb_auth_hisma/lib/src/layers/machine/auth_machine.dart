import 'package:firebase_auth/firebase_auth.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../assistance.dart';
import '../../components/signed_in/layers/machine/signed_in_machine.dart';
import '../../components/signed_out/layers/machines/signed_out_machine.dart';

const String loggerName = 'auth_machine';
final log = getLogger(loggerName);

const String authMachineName = 'authMachine';

enum SAM { signedOut, signedIn, init }

enum EAM { signIn, signOut }

enum TAM { toSignedOut, toSignedIn }

StateMachineWithChangeNotifier<SAM, EAM, TAM> createAuthMachine() =>
    StateMachineWithChangeNotifier<SAM, EAM, TAM>(
      events: EAM.values,
      name: authMachineName,
      initialStateId: SAM.init,
      states: {
        SAM.init: State(
          etm: {
            EAM.signIn: [TAM.toSignedIn],
            EAM.signOut: [TAM.toSignedOut],
          },
          onEntry: _createAuthChangeAction(),
        ),
        SAM.signedOut: State(
          etm: {
            EAM.signIn: [TAM.toSignedIn],
          },
          regions: [
            Region<SAM, EAM, TAM, SSoM>(machine: createSignedOutMachine()),
          ],
        ),
        SAM.signedIn: State(
          etm: {
            EAM.signOut: [TAM.toSignedOut],
          },
          regions: [
            Region<SAM, EAM, TAM, SSiM>(machine: createSignedInMachine())
          ],
        ),
      },
      transitions: {
        TAM.toSignedIn: Transition(to: SAM.signedIn),
        TAM.toSignedOut: Transition(to: SAM.signedOut),
      },
    );

Action _createAuthChangeAction() => Action(
      // TODO: move these to assistance layer.
      description: 'Set callbacks for auth change.',
      action: (machine, dynamic arg) async {
        // await Firebase.initializeApp(
        //   options: DefaultFirebaseOptions.currentPlatform,
        // );
        FirebaseAuth.instance.authStateChanges().listen((user) {
          log.fine('<@> authStateChanges: Email verification status:'
              ' ${user?.emailVerified ?? 'N/A'}');
        });
        FirebaseAuth.instance.idTokenChanges().listen((user) {
          log.fine('<@> idTokenChanges: Email verification status:'
              ' ${user?.emailVerified ?? 'N/A'}');
        });
        FirebaseAuth.instance.userChanges().listen((user) {
          log.fine('<@> userChanges: Email verification status:'
              ' ${user?.emailVerified ?? 'N/A'}');
        });

        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          log.info('////////// authStateChanges /////////////');
          if (user == null) {
            log.info('User is currently signed out!');
            machine.fire(EAM.signOut);
          } else {
            log.info('User is signed in!');
            machine.fire(EAM.signIn);
          }
        });
      },
    );
