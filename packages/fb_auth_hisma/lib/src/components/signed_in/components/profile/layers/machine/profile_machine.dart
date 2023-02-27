import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../assistance/profile.dart';
import '../assistance/profile_assistance.dart';

const String profileMachineName = 'profileMachine';

enum SPM { profile, error }

enum EPM { load, error, update, back }

enum TPM { load, toError, toProfile, update }

StateMachineWithChangeNotifier<SPM, EPM, TPM> createProfileMachine() =>
    StateMachineWithChangeNotifier<SPM, EPM, TPM>(
      events: EPM.values,
      initialStateId: SPM.profile,
      name: profileMachineName,
      states: {
        SPM.profile: State(
          etm: {
            EPM.update: [TPM.update],
            EPM.error: [TPM.toError],
            EPM.load: [TPM.load],
          },
        ),
        SPM.error: State(
          etm: {
            EPM.back: [TPM.toProfile],
          },
        ),
      },
      transitions: {
        TPM.load: InternalTransition(
          onAction: Action(
            description: 'Load profile information',
            action: (machine, dynamic arg) async {
              final profile = ProfileAssistance.getProfile();
              // await Future<void>.delayed(const Duration(seconds: 5));
              machine.data = profile;
            },
          ),
        ),
        TPM.toError: Transition(to: SPM.error),
        TPM.toProfile: Transition(to: SPM.profile),
        TPM.update: InternalTransition(
          onAction: Action(
            description: 'Updating profile',
            action: (machine, dynamic arg) async {
              assert(arg is String);
              await ProfileAssistance.updateProfile(
                Profile(displayName: arg as String),
              );
            },
          ),
        ),
      },
    );
