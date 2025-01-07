import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../ui.dart';
import '../utility.dart';
import 'states_events_transitions.dart';

Future<void> main() async {
  initLogging();
  h.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    // (m) => ConsoleMonitor(m),
  ];
  final machine = createParentChainMachine(
    name: 'root',
    historyLevel: h.HistoryLevel.shallow,
  );
  await machine.start();

  runApp(ChainApp(machine: machine, useRootNavigator: true));
}

StateMachineWithChangeNotifier<S, E, T> createParentChainMachine({
  required String name,
  required h.HistoryLevel? historyLevel,
}) =>
    StateMachineWithChangeNotifier(
      name: name,
      initialStateId: S.a,
      events: E.values,
      states: {
        S.a: h.State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: h.State(
          etm: {
            E.back: [T.toA],
          },
          regions: [
            h.Region<S, E, T, S>(
              machine:
                  createChildMachine(name: 'child', historyLevel: historyLevel),
            )
          ],
        ),
      },
      transitions: {
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
      },
    );

StateMachineWithChangeNotifier<S, E, T> createChildMachine({
  required String name,
  h.HistoryLevel? historyLevel,
}) =>
    StateMachineWithChangeNotifier(
      name: name,
      initialStateId: S.a,
      events: E.values,
      history: historyLevel,
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
            E.back: [T.toE],
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
      },
    );

HismaRouterGenerator<S, E> createParentHismaRouterGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool useRootNavigator,
}) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(widget: Screen(machine)),
        S.b: MaterialPageCreator<E, void>(
          widget: Router(
            routerDelegate: createChildHismaRouterGenerator(
              machine: machine.find('child'),
              useRootNavigator: useRootNavigator,
            ).routerDelegate,
          ),
        ),
      },
    );

HismaRouterGenerator<S, E> createChildHismaRouterGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool useRootNavigator,
}) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(widget: Screen(machine)),
        S.b: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
        S.d: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.back,
        ),
        S.e: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
        S.f: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.back,
        ),
      },
    );

class ChainApp extends StatelessWidget {
  ChainApp({
    required StateMachineWithChangeNotifier<S, E, T> machine,
    required bool useRootNavigator,
    super.key,
  }) : _routerGenerator = createParentHismaRouterGenerator(
          machine: machine,
          useRootNavigator: useRootNavigator,
        );

  final HismaRouterGenerator<S, E> _routerGenerator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Navigator Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: _routerGenerator.routerDelegate,
      routeInformationParser: _routerGenerator.routeInformationParser,
    );
  }
}
