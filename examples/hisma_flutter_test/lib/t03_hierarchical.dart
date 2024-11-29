import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hm;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'machine_simple.dart';
import 'ui.dart';
import 'utility.dart';

void main(List<String> args) {
  initLogging();
  hm.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  runApp(HierarchicalApp(createSimpleMachine(hierarchical: true)..start()));
}

class HierarchicalApp extends StatelessWidget {
  HierarchicalApp(this.machine, {super.key})
      : generator = createHierarchicalGenerator(machine);

  final HismaRouterGenerator<S, E> generator;

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: generator.routerDelegate,
    );
  }
}

HismaRouterGenerator<S, E> createHierarchicalGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine, [
  int level = 0,
]) =>
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
          overlay: true,
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.c),
          event: E.back,
          overlay: true,
        ),
        S.d: level < 2
            ? MaterialPageCreator<E, void>(
                // TODO: Create utility router class that creates
                // BackButtonDispatcher.
                widget: Builder(
                  builder: (context) {
                    return Router(
                      routerDelegate: createHierarchicalGenerator(
                        machine.find('$testMachineName${level + 1}'),
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
              )
            : MaterialPageCreator<E, void>(
                widget: Screen(machine, S.d),
                event: E.back,
              ),
      },
    );
