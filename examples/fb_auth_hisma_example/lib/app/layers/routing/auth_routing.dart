import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/widgets.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../components/signed_in/layers/routing/signed_in_routing.dart';
import '../../components/signed_out/layers/routing/routing.dart';
import '../machine/auth_machine.dart';
import '../ui/init_screen.dart';

final appRouter = HismaRouterGenerator<SAM, EAM>(
  machine: authMachine,
  mapping: {
    SAM.init: MaterialPageCreator<EAM, void>(widget: const InitScreen()),
    SAM.signedOut: MaterialPageCreator<EAM, void>(
      widget: Router(routerDelegate: signedOutRouter.routerDelegate),
    ),
    SAM.signedIn: MaterialPageCreator<EAM, void>(
      widget: Router(routerDelegate: signedInRouter.routerDelegate),
    ),
  },
);
