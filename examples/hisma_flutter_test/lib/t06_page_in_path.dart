import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'ui.dart';

Future<void> main(List<String> args) async {
  h.Machine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createParentMachine();
  await machine.start();
  final app = PageInPathApp(machine: machine, rootNavigator: false);
  runApp(app);
}

class PageInPathApp extends StatelessWidget {
  PageInPathApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final gen =
      createParentGenerator(machine: machine, rootNavigator: rootNavigator);

  final NavigationMachine<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createParentGenerator({
  required NavigationMachine<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine),
        ),
        S.b: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          event: E.back,
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Router(
            routerDelegate: createChildGenerator(
              machine: machine.find(child1),
              rootNavigator: rootNavigator,
            ).routerDelegate,
          ),
          overlay: true,
        ),
        S.d: MaterialPageCreator<E, void>(
          widget: Router(
            routerDelegate: createChildGenerator(
              machine: machine.find(child2),
              rootNavigator: rootNavigator,
            ).routerDelegate,
          ),
          overlay: true,
        ),
        S.e: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
        S.f: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          // overlay: true,
          event: E.back,
        ),
      },
    );

HismaRouterGenerator<S, E> createChildGenerator({
  required NavigationMachine<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine),
        ),
        S.b: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
        S.c: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          event: E.back,
        ),
        S.d: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          event: E.back,
        ),
        S.e: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
        S.f: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
        S.g: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          event: E.back,
        ),
      },
    );

enum S { a, b, c, d, e, f, g }

enum E { forward, fwdC, fwdD, back, self, restart, stop }

enum T { toA, toB, toC, toD, toE, toF, toG, restart, stop }

const parent = 'parent';
NavigationMachine<S, E, T> createParentMachine() => NavigationMachine(
      name: parent,
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: h.State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: h.State(
          etm: {
            E.fwdC: [T.toC],
            E.fwdD: [T.toD],
            E.back: [T.toA],
            E.restart: [T.restart],
          },
        ),
        S.c: h.State(
          etm: {
            E.back: [T.toB],
            E.fwdD: [T.toD],
            E.self: [T.toC],
          },
          regions: [
            h.Region<S, E, T, S>(machine: createChild1Machine()),
          ],
        ),
        S.d: h.State(
          etm: {
            E.back: [T.toB],
            E.fwdC: [T.toC],
            E.forward: [T.toE],
            E.self: [T.toD],
          },
          regions: [
            h.Region<S, E, T, S>(machine: createChild2Machine()),
          ],
        ),
        S.e: h.State(
          etm: {
            E.back: [T.toD],
            E.forward: [T.toF],
            E.self: [T.toE],
          },
        ),
        S.f: h.State(
          etm: {
            E.back: [T.toE],
            E.self: [T.toF],
            E.restart: [T.restart],
            E.stop: [T.stop],
            E.forward: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
        T.restart: h.InternalTransition(
          onAction: h.Action(
            description: 'restart machine',
            action: (machine, dynamic _) async {
              // print('Restart machine.');
              await machine.stop();
              await machine.start();
            },
          ),
        ),
        T.stop: h.InternalTransition(
          onAction: h.Action(
            description: 'stop machine',
            action: (machine, dynamic _) async {
              // print('Stop machine.');
              await machine.stop();
            },
          ),
        ),
        T.toE: h.Transition(to: S.e),
        T.toF: h.Transition(to: S.f),
      },
    );

const String child1 = 'child1';
NavigationMachine<S, E, T> createChild1Machine() => NavigationMachine(
      name: child1,
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: h.State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: h.State(
          etm: {
            E.forward: [T.toC],
            E.back: [T.toA],
          },
        ),
        S.c: h.State(
          etm: {
            E.forward: [T.toD],
            E.back: [T.toB],
          },
        ),
        S.d: h.State(
          etm: {
            E.forward: [T.toE],
            E.back: [T.toC],
          },
        ),
        S.e: h.State(
          etm: {
            E.forward: [T.toF],
            E.back: [T.toD],
          },
        ),
        S.f: h.State(
          etm: {
            E.forward: [T.toG],
            E.back: [T.toE],
          },
        ),
        S.g: h.State(
          etm: {
            E.forward: [T.toA],
            E.back: [T.toF],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
        T.toE: h.Transition(to: S.e),
        T.toF: h.Transition(to: S.f),
        T.toG: h.Transition(to: S.g),
      },
    );

const String child2 = 'child2';
NavigationMachine<S, E, T> createChild2Machine() => NavigationMachine(
      name: child2,
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: h.State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: h.State(
          etm: {
            E.forward: [T.toC],
            E.back: [T.toA],
          },
        ),
        S.c: h.State(
          etm: {
            E.forward: [T.toD],
            E.back: [T.toB],
          },
        ),
        S.d: h.State(
          etm: {
            E.forward: [T.toE],
            E.back: [T.toC],
          },
        ),
        S.e: h.State(
          etm: {
            E.forward: [T.toF],
            E.back: [T.toD],
          },
        ),
        S.f: h.State(
          etm: {
            E.forward: [T.toG],
            E.back: [T.toE],
          },
        ),
        S.g: h.State(
          etm: {
            E.forward: [T.toA],
            E.back: [T.toF],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
        T.toE: h.Transition(to: S.e),
        T.toF: h.Transition(to: S.f),
        T.toG: h.Transition(to: S.g),
      },
    );
