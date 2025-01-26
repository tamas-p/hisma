import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../assistance/main_assistance.dart';

const String mainMachineName = 'mainMachine';

enum SMM { check, emailNotVerified, error, app }

enum EMM { emailNotVerified, emailVerified, resendEmail, reload, error, back }

enum TMM { toEmailNotVerified, reload, toApp, resendEmail, toError, back }

NavigationMachine<SMM, EMM, TMM> createMainMachine() =>
    NavigationMachine<SMM, EMM, TMM>(
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
            action: (machine, dynamic arg) async {
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
          onEntry: Action(
            description: 'Set data to arg.',
            action: (machine, dynamic arg) async => machine.data = arg,
          ),
        ),
        SMM.app: State(),
      },
      transitions: {
        TMM.toEmailNotVerified: Transition(to: SMM.emailNotVerified),
        TMM.toApp: Transition(to: SMM.app),
        TMM.reload: InternalTransition(
          onAction: Action(
            description: 'Reloading user profile.',
            action: (machine, dynamic arg) async {
              machine.data = await reload();
            },
          ),
        ),
        TMM.resendEmail: InternalTransition(
          minInterval: const Duration(minutes: 1),
          onAction: Action(
            description: 'Resending verification email.',
            action: (machine, dynamic arg) async {
              await sendEmailVerification();
            },
          ),
          onSkip: OnSkipAction(
            description: 'Fire EMM.error.',
            action: (machine, onErrorData) async {
              log.info(onErrorData.message);
              await machine.fire(EMM.error, arg: onErrorData.message);
            },
          ),
        ),
        TMM.toError: Transition(to: SMM.error),
        TMM.back: Transition(to: SMM.emailNotVerified),
      },
    );
