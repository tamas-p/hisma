import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

Future<void> main(List<String> args) async {
  h.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createMachine();
  await machine.start();
  final app = BottomSheetApp(machine: machine, rootNavigator: true);
  runApp(app);
}

class BottomSheetApp extends StatelessWidget {
  BottomSheetApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final gen =
      createGenerator(machine: machine, rootNavigator: rootNavigator);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

class BsScreen extends StatelessWidget {
  const BsScreen({required this.machine, super.key});

  final StateMachineWithChangeNotifier<S, E, T> machine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BottomSheer Screen')),
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              MyButton(machine: machine),
              TextButton(
                onPressed: () {
                  machine.fire(E.fwdC);
                },
                child: Text(
                  E.fwdC.toString(),
                ),
              ),
              TextButton(
                onPressed: () {
                  machine.fire(E.fwdD);
                },
                child: Text(
                  E.fwdD.toString(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({required this.machine, super.key});
  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        machine.fire(E.fwdB, context: context);
      },
      child: Text(E.fwdB.toString()),
    );
  }
}

HismaRouterGenerator<S, E> createGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: BsScreen(machine: machine),
        ),
        // S.b: PagelessCreator<E, void>(
        //   present: showTestDialog,
        //   rootNavigator: rootNavigator,
        //   machine: machine,
        //   event: E.back,
        // ),
        S.b: BottomSheetCreator(
          event: E.back,
          present: (context, close) {
            return showBottomSheet<void>(
              context: context!,
              builder: (context) => Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () {
                          close();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          machine: machine,
        ),
        S.c: PagelessCreator<E, int>(
          machine: machine,
          rootNavigator: false,
          event: E.back,
          present: (context, rootNavigator, navigatorState, close, machine) =>
              showModalBottomSheet<int>(
            context: context,
            builder: (context) => Container(
              height: 200,
              color: Colors.amber,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('ModalBottomSheet'),
                    ElevatedButton(
                      child: const Text('Close BottomSheet'),
                      onPressed: () {
                        close(99);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        S.d: SnackBarCreator(
          machine: machine,
          event: E.back,
          present: (context, scaffoldMessengerState, close) =>
              scaffoldMessengerState.showSnackBar(
            SnackBar(
              content: const Text('A SnackBar has been shown.'),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  close();
                },
              ),
            ),
          ),
        ),
      },
    );

enum S { a, b, c, d }

enum E { fwdB, fwdC, fwdD, back }

enum T { toA, toB, toC, toD }

StateMachineWithChangeNotifier<S, E, T> createMachine() =>
    StateMachineWithChangeNotifier<S, E, T>(
      initialStateId: S.a,
      events: E.values,
      name: 'bottomSheetMachine',
      states: {
        S.a: h.State(
          etm: {
            E.fwdB: [T.toB],
            E.fwdC: [T.toC],
            E.fwdD: [T.toD],
          },
        ),
        S.b: h.State(
          etm: {
            E.back: [T.toA],
          },
        ),
        S.c: h.State(
          etm: {
            E.back: [T.toA],
          },
        ),
        S.d: h.State(
          etm: {
            E.back: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(
          to: S.a,
          onAction: h.Action(
            description: 'print return value',
            action: (machine, dynamic arg) {
              print('arg: $arg');
            },
          ),
        ),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
      },
    );
