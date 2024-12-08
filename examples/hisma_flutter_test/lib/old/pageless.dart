import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../ui.dart';
import 'states_events_transitions.dart';

StateMachineWithChangeNotifier<S, E, T> createPagelessMachine({
  required String name,
}) =>
    StateMachineWithChangeNotifier<S, E, T>(
      name: name,
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
            E.back: [T.toA],
            E.forward: [T.toC],
            E.self: [T.toN],
          },
        ),
        S.c: h.State(
          etm: {
            E.back: [T.toB],
            E.forward: [T.toD],
          },
        ),
        S.d: h.State(
          etm: {
            E.back: [T.toC],
            E.forward: [T.toE],
          },
        ),
        S.e: h.State(
          etm: {
            E.back: [T.toD],
            E.forward: [T.toF],
          },
        ),
        S.f: h.State(
          etm: {
            E.back: [T.toE],
            E.forward: [T.toA],
          },
        ),
      },
      transitions: {
        // TODO: of by mistake Transition(to: T.toB) is used instead of
        // Transition(to: S.b) there is not type check -> error prone.
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
        T.toE: h.Transition(to: S.e),
        T.toF: h.Transition(to: S.f),
        T.toN: h.InternalTransition(
          onAction: h.Action(
            description: 'Evaluate result.',
            action: (machine, dynamic arg) async {
              // print('Received: $arg');
              if (arg is OldCtxArg && arg.arg is E) {
                if (arg.arg != E.self) {
                  await machine.fire(
                    arg.arg,
                    arg: arg.context,
                    external: false,
                  );
                }
              }
            },
          ),
        ),
      },
    );

HismaRouterGenerator<S, E> createPagelessHismaRouterGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool useRootNavigator,
}) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(widget: Screen(machine, S.a)),
        S.b: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.self,
        ),
        S.c: PagelessCreator<E, DateTime?>(
          present: showTestDatePicker,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.forward,
        ),
        S.d: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.forward,
        ),
        S.e: MaterialPageCreator<E, void>(widget: Screen(machine, S.e)),
        S.f: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.back,
        ),
      },
    );

class PagelessApp extends StatelessWidget {
  PagelessApp({
    required StateMachineWithChangeNotifier<S, E, T> machine,
    required bool useRootNavigator,
    super.key,
  }) : _routerGenerator = createPagelessHismaRouterGenerator(
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
      // routeInformationParser: _routerGenerator.routeInformationParser,
    );
  }
}

Future<void> main() async {
  // initLogging();
  h.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    // (m) => ConsoleMonitor(m),
  ];
  final machine = createPagelessMachine(name: 'root');
  await machine.start();

  runApp(PagelessApp(machine: machine, useRootNavigator: true));
}
