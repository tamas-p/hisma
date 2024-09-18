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
  runApp(OverlayApp(createSimpleMachine()));
}

class OverlayApp extends StatelessWidget {
  const OverlayApp(this.machine, {super.key});

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: createOverlayGenerator(machine).routerDelegate,
    );
  }
}

HismaRouterGenerator<S, E> createOverlayGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine,
) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<void, void>(widget: Screen(machine, S.a)),
        S.b: MaterialPageCreator<void, void>(
          widget: Screen(machine, S.b),
          overlay: true,
        ),
        S.c: MaterialPageCreator<void, void>(
          widget: Screen(machine, S.c),
          overlay: true,
        ),
      },
    );
