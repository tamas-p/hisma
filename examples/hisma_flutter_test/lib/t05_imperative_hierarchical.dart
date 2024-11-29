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
  final machine = createLongerMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalImperativeApp(machine);
  runApp(app);
}

class HierarchicalImperativeApp extends StatelessWidget {
  HierarchicalImperativeApp(this.machine, {super.key});
  final generators = Generators();
  late final gen = generators.createHierarchicalImpGenerator(machine);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

class Generators {
  HismaRouterGenerator<S, E> createHierarchicalImpGenerator(
    StateMachineWithChangeNotifier<S, E, T> parentMachine, [
    int level = 0,
  ]) {
    final state = parentMachine.activeStateId;
    // final name = '$testMachineName$level${level == 0 ? '' : state ?? ''}';
    final name = getMachineName(parentMachine.name, state);
    final machine =
        level == 0 ? parentMachine : parentMachine.find<S, E, T>(name);

    final generator = HismaRouterGenerator<S, E>(
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
          machine: machine,
          event: E.back,
        ),
        S.e: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.f: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.g: level < 2
            ? MaterialPageCreator<E, void>(
                // TODO: Create utility router class that creates
                // BackButtonDispatcher.
                widget: Builder(
                  builder: (context) {
                    return Router(
                      routerDelegate: createHierarchicalImpGenerator(
                        machine,
                        level + 1,
                      ).routerDelegate,
                      backButtonDispatcher: Router.of(context)
                          .backButtonDispatcher!
                          .createChildBackButtonDispatcher()
                        ..takePriority(),
                    );
                  },
                ),
                event: E.back,
                overlay: true,
              )
            : MaterialPageCreator<E, void>(
                widget: Screen(machine, S.g),
                event: E.back,
                overlay: true,
              ),
        S.h: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.i: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.j: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.k: level < 2
            ? MaterialPageCreator<E, void>(
                // TODO: Create utility router class that creates
                // BackButtonDispatcher.
                widget: Builder(
                  builder: (context) {
                    return Router(
                      routerDelegate: createHierarchicalImpGenerator(
                        machine,
                        level + 1,
                      ).routerDelegate,
                      backButtonDispatcher: Router.of(context)
                          .backButtonDispatcher!
                          .createChildBackButtonDispatcher()
                        ..takePriority(),
                    );
                  },
                ),
                event: E.back,
                overlay: true,
              )
            : MaterialPageCreator<E, void>(
                widget: Screen(machine, S.k),
                event: E.back,
                overlay: true,
              ),
        S.l: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.l),
          event: E.back,
          overlay: true,
        ),
        S.m: NoUIChange(),
      },
    );

    return generator;
  }
}
