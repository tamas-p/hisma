import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hm;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'simple_machine.dart';
import 'ui.dart';

void main(List<String> args) {
  hm.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  runApp(NoOverlayApp(createSimpleMachine()));
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
        S.a: MaterialPageCreator<T, S, E>(
          widget: Screen(machine, S.a),
          event: E.back,
        ),
        S.b: MaterialPageCreator<T, S, E>(
          widget: Screen(machine, S.b),
          event: E.back,
        ),
        S.c: MaterialPageCreator<T, S, E>(
          widget: Screen(machine, S.c),
          event: E.back,
        ),
      },
    );
