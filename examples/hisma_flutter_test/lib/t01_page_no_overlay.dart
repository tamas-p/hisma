import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hm;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'ui.dart';

void main(List<String> args) {
  hm.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  runApp(NoOverlayApp(createNoOverlayMachine()));
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

enum S { a, b, c }

enum E { forward, back, self }

enum T { toA, toB, toC }

StateMachineWithChangeNotifier<S, E, T> createNoOverlayMachine() =>
    StateMachineWithChangeNotifier<S, E, T>(
      name: 'testMachine',
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: hm.State(
          etm: {
            E.forward: [T.toB],
            E.back: [T.toC],
            E.self: [T.toA],
          },
        ),
        S.b: hm.State(
          etm: {
            E.forward: [T.toC],
            E.back: [T.toA],
            E.self: [T.toB],
          },
        ),
        S.c: hm.State(
          etm: {
            E.forward: [T.toA],
            E.back: [T.toB],
            E.self: [T.toC],
          },
        ),
      },
      transitions: {
        T.toA: hm.Transition(to: S.a),
        T.toB: hm.Transition(to: S.b),
        T.toC: hm.Transition(to: S.c),
      },
    )..start();
