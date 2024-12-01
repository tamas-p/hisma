import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../utility/pageless_route_helper.dart';
import '../../components/comp_a_a/layers/routing/a_a_comp_router_provider.dart';
import '../machine/comp_a_machine.dart';
import '../ui/comp_a_screen_b.dart';
import '../ui/comp_a_screen_c.dart';

final aRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, E>(
    machine: ref.read(compAMachineProvider),
    mapping: {
      // S.ca: MaterialPageCreator<S>(widget: const CompAScreenA()),
      S.ca: MaterialPageCreator<E, void>(
        // widget: const StatelessScreen(),
        // widget: const StatefulScreen(),
        widget:
            Router(routerDelegate: ref.read(l2aRouterProvider).routerDelegate),
      ),
      S.ca1: PagelessCreator<E, void>(
        event: E.int1,
        present: (
          BuildContext context,
          bool rootNavigator,
          NavigatorState _,
          Close<DateTime> close,
          StateMachineWithChangeNotifier<dynamic, dynamic, dynamic> machine,
        ) =>
            generateDialog<void, E>(
          context: context,
          rootNavigator: rootNavigator,
          title: 'Problem during login ca1',
          text: 'Hello ca1.',
        ),
        machine: ref.read(compAMachineProvider),
      ),
      S.ca2: NoUIChange(),
      S.cb: MaterialPageCreator<E, void>(widget: const CompAScreenB()),
      S.cc: MaterialPageCreator<E, void>(widget: const CompAScreenC()),
    },
  ),
);
