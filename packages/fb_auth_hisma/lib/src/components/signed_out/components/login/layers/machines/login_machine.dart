import 'package:firebase_auth/firebase_auth.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../assistance.dart';
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
          onEntry: Action(
            description: 'set data to arg',
            action: (machine, dynamic arg) async {
              machine.data = arg;
            },
          ),
        ),
      },
      transitions: {
        TLiM.toEmailSigningIn: Transition(
          to: SLiM.emailSigningIn,
          guard: Guard(
            description: 'Only if password is not empty.',
            condition: (machine, dynamic data) async {
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
      action: (machine, dynamic arg) async {
        assert(arg is Credentials);
        final uCredentials = arg as Credentials;

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
            case 'configuration-not-found':
              _log.info('Handled Auth error: ${e.code}');
              break;
            default:
              _log.info('Not handled Auth error: ${e.code}');
              break;
          }
          machine.fire(ELiM.fail, arg: e.code);
        }
      },
    );
