import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hm;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'machine_longer.dart';
import 'ui.dart';

Future<void> main(List<String> args) async {
  hm.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createLongerMachine();
  await machine.start();
  runApp(ImperativeApp(machine));
}

class ImperativeApp extends StatelessWidget {
  ImperativeApp(this.machine, {super.key});
  late final gen = createImperativeGenerator(machine);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createImperativeGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine,
) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.a),
          event: E.back,
        ),
        S.b: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.c: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.d: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.e: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.e),
          event: E.back,
          overlay: true,
        ),
        S.f: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.g: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.h: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.i: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.i),
          event: E.back,
          overlay: true,
        ),
      },
    );
