import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../assistance/profile.dart';
import '../assistance/profile_assistance.dart';

const String profileMachineName = 'profileMachine';

enum SPM { profile, error }

enum EPM { load, error, update, back }

enum TPM { load, toError, toProfile, toProfileWithUpdate }

StateMachineWithChangeNotifier<SPM, EPM, TPM> createProfileMachine() =>
    StateMachineWithChangeNotifier<SPM, EPM, TPM>(
      events: EPM.values,
      initialStateId: SPM.profile,
      name: profileMachineName,
      states: {
        SPM.profile: State(
          etm: {
            EPM.update: [TPM.toProfileWithUpdate],
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
        TPM.load: Transition(
          to: SPM.profile,
          onAction: Action(
            description: 'Load profile information',
            action: (machine, dynamic parameter) async {
              final profile = ProfileAssistance.getProfile();
              // await Future<void>.delayed(const Duration(seconds: 5));
              machine.data = profile;
            },
          ),
        ),
        TPM.toError: Transition(to: SPM.error),
        TPM.toProfile: Transition(to: SPM.profile),
        TPM.toProfileWithUpdate: Transition(
          to: SPM.profile,
          onAction: Action(
            description: 'Updating profile',
            action: (machine, dynamic parameter) async {
              assert(machine.data is String);
              await ProfileAssistance.updateProfile(
                Profile(displayName: machine.data as String),
              );
            },
          ),
        ),
      },
    );
