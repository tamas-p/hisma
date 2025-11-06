import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../ui.dart';
import '../utility.dart';
import 'states_events_transitions.dart';

Future<void> main() async {
  initLogging();
  h.Machine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    // (m) => ConsoleMonitor(m),
  ];
  final machine = createConcurrentMachine();
  await machine.start();

  runApp(DoubleApp(machine: machine));
}

NavigationMachine<S, E, T> createConcurrentMachine() => NavigationMachine(
      events: E.values,
      name: 'concurrentMachine',
      initialStateId: S.a,
      states: {
        S.a: h.State(
          etm: {
            E.forward: [T.toB],
            E.jump: [T.toC],
          },
        ),
        S.b: h.State(
          onEntry: h.Action(
            description: 'sleep',
            action: (machine, dynamic arg) async {
              await Future<void>.delayed(const Duration(seconds: 3));
            },
          ),
          etm: {
            E.forward: [T.toB],
            E.jump: [T.toC],
            E.back: [T.toA],
          },
        ),
        S.c: h.State(
          etm: {
            E.forward: [T.toB],
            E.jump: [T.toC],
            E.back: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
      },
    );
HismaRouterGenerator<S, E> createConcurrentHismaRouterGenerator({
  required NavigationMachine<S, E, T> machine,
}) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: DoubleScreen(machine: machine),
        ),
        S.b: PagelessCreator<E, void>(
          presenter: PresentTestDialog(machine),
          rootNavigator: true,
          event: E.back,
        ),
        S.c: PagelessCreator<E, void>(
          presenter: PresentTestDialog(machine),
          rootNavigator: true,
          event: E.back,
        )
      },
    );

class DoubleScreen extends StatelessWidget {
  const DoubleScreen({super.key, required this.machine});
  final NavigationMachine<S, E, T> machine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoubleScreen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('sub1 screen'),
              ),
              floatingActionButton: Builder(
                builder: (context) {
                  return FloatingActionButton(
                    onPressed: () {
                      machine.fire(E.forward, arg: context);
                    },
                    child: const Text('Sub1'),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('sub2 screen'),
              ),
              floatingActionButton: Builder(
                builder: (context) {
                  return FloatingActionButton(
                    onPressed: () {
                      machine.fire(E.jump, arg: context);
                    },
                    child: const Text('Sub2'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*Future<void> showMyBottomSheet(
  BuildContext context,
  String str,
) async {
// showModalBottomSheet(
//   context: context,
//   builder:
  final ret = Scaffold.of(context).showBottomSheet<void>(
    (BuildContext context) {
      return Container(
        height: 200,
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('BottomSheet: $str'),
              ElevatedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
  return ret.closed;
}
*/

class DoubleApp extends StatelessWidget {
  DoubleApp({
    required NavigationMachine<S, E, T> machine,
    super.key,
  }) : _routerGenerator = createConcurrentHismaRouterGenerator(
          machine: machine,
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
