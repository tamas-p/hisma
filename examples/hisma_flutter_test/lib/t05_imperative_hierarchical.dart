import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hm;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'machine_longer.dart';
import 'ui.dart';

Future<void> main(List<String> args) async {
  hm.Machine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createLongerMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalImperativeApp(machine: machine, rootNavigator: false);
  runApp(app);
}

class HierarchicalImperativeApp extends StatelessWidget {
  HierarchicalImperativeApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final gen = createHierarchicalImpGenerator(
    machine: machine,
    rootNavigator: rootNavigator,
  );

  final NavigationMachine<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createHierarchicalImpGenerator({
  required NavigationMachine<S, E, T> machine,
  required bool rootNavigator,
}) {
  final generator = HismaRouterGenerator<S, E>(
    machine: machine,
    mapping: {
      S.a: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        event: E.back,
      ),
      S.b: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        overlay: true,
        event: E.back,
      ),
      S.c: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        overlay: true,
        event: E.back,
      ),
      S.d: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: rootNavigator,
        event: E.back,
      ),
      S.e: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: rootNavigator,
        event: E.back,
      ),
      S.f: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: rootNavigator,
        event: E.back,
      ),
      S.g: machine.name.split('/').length < 3
          ? MaterialPageCreator<E, void>(
              widget: Builder(
                builder: (context) {
                  return RouterWithDelegate<S>(
                    () => createHierarchicalImpGenerator(
                      machine: machine
                          .find<S, E, T>(getMachineName(machine.name, S.g)),
                      rootNavigator: rootNavigator,
                    ).routerDelegate,
                    key: const ValueKey(S.g),
                  );
                },
              ),
              event: E.back,
              overlay: true,
            )
          : MaterialPageCreator<E, void>(
              widget: Screen(machine),
              event: E.back,
              overlay: true,
            ),
      S.h: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: rootNavigator,
        event: E.back,
      ),
      S.i: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: rootNavigator,
        event: E.back,
      ),
      S.j: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: rootNavigator,
        event: E.back,
      ),
      S.k: machine.name.split('/').length < 3
          ? MaterialPageCreator<E, void>(
              widget: Builder(
                builder: (context) {
                  return RouterWithDelegate<S>(
                    () => createHierarchicalImpGenerator(
                      machine: machine.find<S, E, T>(
                        getMachineName(machine.name, S.k),
                      ),
                      rootNavigator: rootNavigator,
                    ).routerDelegate,
                    key: const ValueKey(S.k),
                  );
                },
              ),
              event: E.back,
              overlay: true,
            )
          : MaterialPageCreator<E, void>(
              widget: Screen(machine),
              event: E.back,
              overlay: true,
            ),
      S.l: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        event: E.back,
        overlay: true,
      ),
      S.m: NoUIChange(),
    },
  );

  return generator;
}
