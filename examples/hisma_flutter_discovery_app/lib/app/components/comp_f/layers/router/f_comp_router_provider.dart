import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../utility/pageless_route_helper.dart';
import '../machine/comp_f_machine.dart';
import '../ui/comp_f_screen_a.dart';
import '../ui/comp_f_screen_c.dart';

final fRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, E>(
    machine: ref.read(compFMachineProvider),
    mapping: {
      S.fa: MaterialPageCreator<E, void>(widget: const CompFScreenA()),
      // S.fb: getPagelessCreator2(),
      S.fb: DialogCreator<E, void>(
        useRootNavigator: true,
        event: E.backward,
        show: (dc, context) => generateDialog(
          dc: dc,
          context: context,
          title: 'Test1',
          text: 'Demo test1.',
        ),
      ),
      // S.b: MaterialPageCreator<S>(widget: const CompFScreenB()),
      S.fc: MaterialPageCreator<E, void>(widget: const CompFScreenC()),
    },
  ),
);
