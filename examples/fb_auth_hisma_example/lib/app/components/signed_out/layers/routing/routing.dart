import 'package:fb_auth_hisma/fb_auth_hisma.dart';
import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../layers/machine/auth_machine.dart';
import '../../components/login/layers/routing/login_routing.dart';
import '../../components/register/layers/routing/registration_router_generator.dart';

final signedOutRouter = HismaRouterGenerator<SSoM, ESoM>(
  machine: authMachine.find<SSoM, ESoM, TSoM>(signedOutMachineName),
  mapping: {
    SSoM.login: MaterialPageCreator<ESoM, void>(
      widget: Router(routerDelegate: loginRouter.routerDelegate),
    ),
    SSoM.registration: MaterialPageCreator<ESoM, void>(
      widget: Router(
        routerDelegate: registrationRouterGenerator.routerDelegate,
      ),
    ),
  },
);
