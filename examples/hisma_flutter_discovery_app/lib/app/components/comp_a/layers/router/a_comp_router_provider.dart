import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../utility/pageless_route_helper.dart';
import '../../components/comp_a_a/layers/routing/a_a_comp_router_provider.dart';
import '../machine/comp_a_machine.dart';
import '../ui/comp_a_screen_b.dart';
import '../ui/comp_a_screen_c.dart';

final aRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, Widget, E>(
    machine: ref.read(compAMachineProvider),
    mapping: {
      // S.ca: MaterialPageCreator<S>(widget: const CompAScreenA()),
      S.ca: MaterialPageCreator<S>(
        // widget: const StatelessScreen(),
        // widget: const StatefulScreen(),
        widget:
            Router(routerDelegate: ref.read(l2aRouterProvider).routerDelegate),
      ),
      S.ca1: PagelessCreator<bool, E>(
        event: E.int1,
        // event: E.backward,
        pagelessRouteManager: DialogPagelessRouteManager(
          title: 'Problem during login ca1',
          text: 'Hello ca1.',
        ),
      ),
      S.ca2: NoUIChange(),
      S.cb: MaterialPageCreator<S>(widget: const CompAScreenB()),
      S.cc: MaterialPageCreator<S>(widget: const CompAScreenC()),
    },
  ),
);
