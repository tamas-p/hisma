import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../layers/machine/auth_machine.dart';
import '../../components/main/layers/routing/main_router.dart';
import '../../components/profile/layers/routing/profile_routing.dart';
import '../ui/sign_out_confirmation_dialog.dart';

final signedInRouter = HismaRouterGenerator<SSiM, ESiM>(
  machine: authMachine.find<SSiM, ESiM, TSiM>(signedInMachineName),
  mapping: {
    // S.main: MaterialPageCreator<S>(widget: const SignedInScreen()),
    SSiM.main: MaterialPageCreator<ESiM, void>(
      widget: Router(routerDelegate: mainRouter.routerDelegate),
    ),
    SSiM.confirmSignOut: PagelessCreator<ESiM, void>(
      present: signOutConfirmationDialog,
      rootNavigator: true,
      event: ESiM.cancel,
    ),
    SSiM.profile: MaterialPageCreator<ESiM, void>(
      widget: Router(routerDelegate: profileRouter.routerDelegate),
      event: ESiM.back,
      overlay: true,
    ),
  },
);
