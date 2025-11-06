import 'package:flutter/material.dart';
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
      S.fb: PagelessCreator<E, void>(
        event: E.backward,
        presenter: PresentDialogTest1(),
        rootNavigator: true,
      ),
      // S.b: MaterialPageCreator<S>(widget: const CompFScreenB()),
      S.fc: MaterialPageCreator<E, void>(widget: const CompFScreenC()),
    },
  ),
);

class PresentDialogTest1 implements Presenter<void> {
  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<void> close,
    required dynamic fireArg,
  }) =>
      generateDialog<void, E>(
        context: context,
        rootNavigator: rootNavigator,
        title: 'Test1',
        text: 'Demo test1.',
      );
}
