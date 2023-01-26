import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../components/main/layers/machine/main_machine.dart';
import '../../components/profile/layers/machine/profile_machine.dart';
import '../assistance/sign_out_assistance.dart';

const String signedInMachineName = 'signedInMachine';

enum SSiM { main, confirmSignOut, profile }

enum ESiM { intentSignOut, initiateSignOut, profile, cancel, back, error }

enum TSiM { toConfirmSignOut, initiateSignOut, toProfile, toMain }

StateMachineWithChangeNotifier<SSiM, ESiM, TSiM> createSignedInMachine() =>
    StateMachineWithChangeNotifier<SSiM, ESiM, TSiM>(
      events: ESiM.values,
      name: signedInMachineName,
      initialStateId: SSiM.main,
      states: {
        SSiM.main: State(
          etm: {
            ESiM.intentSignOut: [TSiM.toConfirmSignOut],
            ESiM.profile: [TSiM.toProfile],
          },
          regions: [
            Region<SSiM, ESiM, TSiM, SMM>(machine: createMainMachine()),
          ],
        ),
        SSiM.confirmSignOut: State(
          etm: {
            ESiM.cancel: [TSiM.toMain],
            ESiM.initiateSignOut: [TSiM.initiateSignOut],
          },
        ),
        SSiM.profile: State(
          etm: {
            ESiM.back: [TSiM.toMain],
          },
          regions: [
            Region<SSiM, ESiM, TSiM, SPM>(machine: createProfileMachine())
          ],
        ),
      },
      transitions: {
        TSiM.toConfirmSignOut: Transition(to: SSiM.confirmSignOut),
        TSiM.toMain: Transition(to: SSiM.main),
        TSiM.initiateSignOut: Transition(
          to: SSiM.confirmSignOut,
          onAction: Action(
            description: 'Initiate sign out',
            action: (machine, dynamic arg) async {
              signOut();
            },
          ),
        ),
        TSiM.toProfile: Transition(to: SSiM.profile),
      },
    );
