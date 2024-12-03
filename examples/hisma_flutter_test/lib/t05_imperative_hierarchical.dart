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
  final app = HierarchicalImperativeApp(machine: machine, rootNavigator: true);
  runApp(app);
}

class HierarchicalImperativeApp extends StatelessWidget {
  HierarchicalImperativeApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final generators = Generators(rootNavigator: rootNavigator);
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
  Generators({required this.rootNavigator});
  bool rootNavigator;
  // This map is needed to support hot reload as child Routers will
  // be rebuilt and loose their HismaRouterDelegate state but the corresponding
  // machine active state is preserved.
  // TODO: it might be better with a similar approach as Widgets finds their
  // elements and state. Then we would not need to explicitly manage this.
  final generators = <String, HismaRouterGenerator<S, E>>{};
  HismaRouterGenerator<S, E> createHierarchicalImpGenerator(
    StateMachineWithChangeNotifier<S, E, T> machine,
  ) {
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
        S.g: machine.name.split('/').length < 3
            ? MaterialPageCreator<E, void>(
                // TODO: Create utility router class that creates
                // BackButtonDispatcher.
                widget: Builder(
                  builder: (context) {
                    return Router(
                      routerDelegate: (generators.putIfAbsent(
                        getMachineName(machine.name, S.g),
                        () => createHierarchicalImpGenerator(
                          machine.find<S, E, T>(
                            getMachineName(machine.name, S.g),
                          ),
                        ),
                      )).routerDelegate,
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
        S.k: machine.name.split('/').length < 3
            ? MaterialPageCreator<E, void>(
                // TODO: Create utility router class that creates
                // BackButtonDispatcher.
                widget: Builder(
                  builder: (context) {
                    return Router(
                      routerDelegate: generators
                          .putIfAbsent(
                            getMachineName(machine.name, S.k),
                            () => createHierarchicalImpGenerator(
                              machine.find<S, E, T>(
                                getMachineName(machine.name, S.k),
                              ),
                            ),
                          )
                          .routerDelegate,
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
