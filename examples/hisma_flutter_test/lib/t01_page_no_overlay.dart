import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hm;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'simple_machine.dart';
import 'ui.dart';

Future<void> main(List<String> args) async {
  hm.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createSimpleMachine();
  await machine.start();
  runApp(NoOverlayApp(machine));
}

class NoOverlayApp extends StatelessWidget {
  NoOverlayApp(this.machine, {super.key});
  late final gen = createNoOverlayGenerator(machine);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createNoOverlayGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine,
) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.a),
          event: E.back,
        ),
        S.b: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.b),
          event: E.back,
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.c),
          event: E.back,
        ),
        S.d: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.d),
          event: E.back,
        ),
      },
    );
