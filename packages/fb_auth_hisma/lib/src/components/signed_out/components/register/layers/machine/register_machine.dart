import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../assistance.dart';
import '../../../../../../layers/assistance/auth_assistance.dart';
import '../../../login/layers/assistance/login_assistance.dart';
import '../assistance/registration_assistance.dart';

final _log = getLogger(registerMachineName);

const String registerMachineName = 'registerMachine';

enum SRM { registration, failed, exBack }

enum ERM { back, register, fail, ok }

enum TRM { register, toFailed, toRegistration, toExBack }

NavigationMachine<SRM, ERM, TRM> createRegisterMachine() =>
    NavigationMachine<SRM, ERM, TRM>(
      events: ERM.values,
      name: registerMachineName,
      initialStateId: SRM.registration,
      states: {
        SRM.registration: State(
          etm: {
            ERM.register: [TRM.register],
            ERM.fail: [TRM.toFailed],
            ERM.back: [TRM.toExBack],
          },
        ),
        SRM.failed: State(
          etm: {
            ERM.ok: [TRM.toRegistration],
          },
          onEntry: Action(
            description: 'set data to arg',
            action: (machine, dynamic arg) async {
              machine.data = arg;
            },
          ),
        ),
        SRM.exBack: ExitPoint(),
      },
      transitions: {
        TRM.register: InternalTransition(
          onAction: Action(
            description: 'Registering user',
            action: (machine, dynamic arg) async {
              assert(arg is Credentials);
              final uCredentials = arg as Credentials;

              try {
                await createUserWithEmailAndPassword(uCredentials);
                // If registration successful it automatically signs-in the user,
                // so we do not need explicitly send to signedIn state.
              } on AuthenticationException catch (e) {
                _log.warning(
                  'Auth error: errorCode:${e.errorCode} message:${e.message}',
                );
                // TODO i18n
                await machine.fire(ERM.fail, arg: e.message);
              }
            },
          ),
        ),
        TRM.toFailed: Transition(to: SRM.failed),
        TRM.toRegistration: Transition(to: SRM.registration),
        TRM.toExBack: Transition(to: SRM.exBack),
      },
    );
