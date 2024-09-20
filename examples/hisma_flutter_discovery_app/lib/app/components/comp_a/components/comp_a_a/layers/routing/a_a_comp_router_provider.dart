import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../../../utility/pageless_route_helper.dart';
import '../machine/comp_a_a_machine.dart';
import '../ui/comp_a_a_screen_a.dart';
import '../ui/comp_a_a_screen_b.dart';
import '../ui/comp_a_a_screen_c.dart';
import '../ui/comp_a_a_screen_o.dart';

final l2aRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, E>(
    machine: ref.read(compL2AMachineProvider),
    mapping: {
      S.l2a: MaterialPageCreator<E, void>(widget: const CompL2AScreenA()),
      S.l2o: MaterialPageCreator<E, int>(
        widget: const CompL2AScreenO(),
        event: E.jump,
        overlay: true,
      ),
      S.l2a1: DialogCreator<E, void>(
        useRootNavigator: true,
        show: (dc, context) => generateDialog<E, void>(
          context: context,
          dc: dc,
          title: 'Problem during login',
          text: 'Hello.',
        ),
        event: E.backward,
      ),
      S.l2b: MaterialPageCreator<E, void>(widget: const CompL2AScreenB()),
      S.l2c: MaterialPageCreator<E, void>(widget: const CompL2AScreenC()),
    },
  ),
);
