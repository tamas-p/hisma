import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../assistance/main_assistance.dart';

const String mainMachineName = 'mainMachine';

enum SMM { check, emailNotVerified, error, app }

enum EMM { emailNotVerified, emailVerified, resendEmail, reload, error, back }

enum TMM { toEmailNotVerified, reload, toApp, resendEmail, toError, back }

StateMachineWithChangeNotifier<SMM, EMM, TMM> createMainMachine() =>
    StateMachineWithChangeNotifier<SMM, EMM, TMM>(
      name: mainMachineName,
      events: EMM.values,
      initialStateId: SMM.check,
      states: {
        SMM.check: State(
          etm: {
            EMM.emailNotVerified: [TMM.toEmailNotVerified],
            EMM.emailVerified: [TMM.toApp],
          },
          onEntry: Action(
            description: 'Check if email is verified.',
            action: (machine, dynamic parameter) async {
              final verified = isEmailVerified();
              if (verified) {
                await machine.fire(EMM.emailVerified);
              } else {
                await machine.fire(EMM.emailNotVerified);
              }
            },
          ),
        ),
        SMM.emailNotVerified: State(
          etm: {
            EMM.emailVerified: [TMM.toApp],
            EMM.resendEmail: [TMM.resendEmail],
            EMM.reload: [TMM.reload],
            EMM.error: [TMM.toError],
          },
        ),
        SMM.error: State(
          etm: {
            EMM.back: [TMM.back],
          },
        ),
        SMM.app: State(),
      },
      transitions: {
        TMM.toEmailNotVerified: Transition(to: SMM.emailNotVerified),
        TMM.toApp: Transition(to: SMM.app),
        TMM.reload: Transition(
          to: SMM.emailNotVerified,
          onAction: Action(
            description: 'Reloading user profile.',
            action: (machine, dynamic parameter) async {
              machine.data = await reload();
            },
          ),
        ),
        TMM.resendEmail: Transition(
          minInterval: const Duration(days: 1),
          to: SMM.emailNotVerified,
          onAction: Action(
            description: 'Resending verification email.',
            action: (machine, dynamic parameter) async {
              await sendEmailVerification();
            },
          ),
        ),
        TMM.toError: Transition(to: SMM.error),
        TMM.back: Transition(to: SMM.emailNotVerified),
      },
    );
