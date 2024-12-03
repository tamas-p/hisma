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
  runApp(ImperativeApp(machine: machine, rootNavigator: true));
}

class ImperativeApp extends StatelessWidget {
  ImperativeApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final gen =
      createImperativeGenerator(machine: machine, rootNavigator: rootNavigator);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createImperativeGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.a),
          event: E.back,
        ),
        S.b: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.b),
          overlay: true,
          event: E.back,
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.c),
          overlay: true,
          event: E.back,
        ),
        S.d: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.e: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.f: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.g: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.g),
          event: E.back,
          overlay: true,
        ),
        S.h: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.i: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.j: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.k: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.k),
          event: E.back,
          overlay: true,
        ),
        S.l: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.l),
          event: E.back,
        ),
        S.m: NoUIChange(),
      },
    );
