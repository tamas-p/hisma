import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../assistance.dart';
import '../../../../../../layers/assistance/auth_assistance.dart';
import '../../../login/layers/assistance/login_assistance.dart';
import '../assistance/registration_assistance.dart';

final _log = getLogger(registerMachineName);

const String registerMachineName = 'registerMachine';

enum SRM { registration, registering, failed, exBack }

enum ERM { back, register, fail, ok }

enum TRM { toRegistering, toFailed, toRest, toExBack }

StateMachineWithChangeNotifier<SRM, ERM, TRM> createRegisterMachine() =>
    StateMachineWithChangeNotifier<SRM, ERM, TRM>(
      events: ERM.values,
      name: registerMachineName,
      initialStateId: SRM.registration,
      states: {
        SRM.registration: State(
          etm: {
            ERM.register: [TRM.toRegistering],
            ERM.back: [TRM.toExBack],
          },
        ),
        SRM.registering: State(
          etm: {
            ERM.fail: [TRM.toFailed],
          },
          onEntry: Action(
            description: 'Registering user',
            action: (machine, dynamic parameter) async {
              assert(parameter is Credentials);
              final uCredentials = parameter as Credentials;

              try {
                await createUserWithEmailAndPassword(uCredentials);
                // If registration successful it automatically signs-in the user,
                // so we do not need explicitly send to signedIn state.
              } on AuthenticationException catch (e) {
                _log.warning(
                  'Auth error: errorCode:${e.errorCode} message:${e.message}',
                );
                // TODO i18n
                await machine.fire(ERM.fail, data: e.message);
              }
            },
          ),
        ),
        SRM.failed: State(
          etm: {
            ERM.ok: [TRM.toRest],
          },
        ),
        SRM.exBack: ExitPoint(),
      },
      transitions: {
        TRM.toRegistering: Transition(to: SRM.registering),
        TRM.toFailed: Transition(to: SRM.failed),
        TRM.toRest: Transition(to: SRM.registration),
        TRM.toExBack: Transition(to: SRM.exBack),
      },
    );
