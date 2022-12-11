import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../components/login/layers/machines/login_machine.dart' as lm;
import '../../components/register/layers/machine/register_machine.dart' as rm;

const String signedOutMachineName = 'signedOutMachine';

enum SSoM { login, registration }

enum ESoM { register, back }

enum TSoM { toRegistration, toLogin }

StateMachineWithChangeNotifier<SSoM, ESoM, TSoM> createSignedOutMachine() =>
    StateMachineWithChangeNotifier<SSoM, ESoM, TSoM>(
      events: ESoM.values,
      name: signedOutMachineName,
      initialStateId: SSoM.login,
      states: {
        SSoM.login: State(
          etm: {
            ESoM.register: [TSoM.toRegistration],
          },
          regions: [
            Region<SSoM, ESoM, TSoM, lm.SLiM>(machine: lm.createLoginMachine()),
          ],
        ),
        SSoM.registration: State(
          etm: {
            ESoM.back: [TSoM.toLogin],
          },
          regions: [
            Region<SSoM, ESoM, TSoM, rm.SRM>(
              machine: rm.createRegisterMachine(),
              exitConnectors: {
                // rm.S.exSuccess: E.back,
                rm.SRM.exBack: ESoM.back,
              },
            ),
          ],
        ),
      },
      transitions: {
        // TODO: if remove this transition, VisualMonitor plantUmlConverter fails.
        // We shall add an assert to somewhere to avoid this happening.
        TSoM.toLogin: Transition(to: SSoM.login),
        TSoM.toRegistration: Transition(to: SSoM.registration),
      },
    );
