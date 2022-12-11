import 'package:firebase_auth/firebase_auth.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../../assistance.dart';
import '../assistance/login_assistance.dart';

final _log = getLogger(loginMachineName);

const String loginMachineName = 'loginMachine';

enum SLiM { login, emailSigningIn, failedSignIn }

enum ELiM { emailSignIn, fail, ok }

enum TLiM { toLogin, toEmailSigningIn, toFailed }

StateMachineWithChangeNotifier<SLiM, ELiM, TLiM> createLoginMachine() =>
    StateMachineWithChangeNotifier<SLiM, ELiM, TLiM>(
      events: ELiM.values,
      name: loginMachineName,
      initialStateId: SLiM.login,
      states: {
        SLiM.login: State(
          etm: {
            ELiM.emailSignIn: [TLiM.toEmailSigningIn],
          },
        ),
        SLiM.emailSigningIn: State(
          etm: {
            ELiM.fail: [TLiM.toFailed],
          },
          onEntry: _createEmailSignInAction(),
        ),
        SLiM.failedSignIn: State(
          etm: {
            ELiM.ok: [TLiM.toLogin],
          },
        ),
      },
      transitions: {
        TLiM.toEmailSigningIn: Transition(
          to: SLiM.emailSigningIn,
          guard: Guard(
            description: 'Only if password is not empty.',
            condition: () {
              return true;
            },
          ),
        ),
        TLiM.toFailed: Transition(to: SLiM.failedSignIn),
        TLiM.toLogin: Transition(to: SLiM.login),
      },
    );

Action _createEmailSignInAction() => Action(
      description: 'Executing email authentication.',
      action: (machine, dynamic parameter) async {
        assert(parameter is Credentials);
        final uCredentials = parameter as Credentials;

        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: uCredentials.email,
            password: uCredentials.password,
          );
          // TODO: not needed as sign-in status is detected.
          // machine.fire(E.success);
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'invalid-email':
            case 'user-disabled':
            case 'user-not-found':
            case 'wrong-password':
              _log.info('Auth error: ${e.code}');
              machine.fire(ELiM.fail, data: e.code);
              break;
            default:
              assert(false, 'Unhandled code: ${e.code}');
          }
        }
      },
    );
