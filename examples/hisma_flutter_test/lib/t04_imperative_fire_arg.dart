import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

Future<void> main(List<String> args) async {
  hisma.Machine.monitorCreators = [
    (m) => VisualMonitor(m),
  ];

  final machine = createImperativeFireArgMachine();
  await machine.start();
  runApp(ImperativeFireArgApp(machine: machine));
}

enum S { a, b }

enum E { forward, backward }

enum T { toA, toB }

NavigationMachine<S, E, T> createImperativeFireArgMachine() =>
    NavigationMachine<S, E, T>(
      events: E.values,
      initialStateId: S.a,
      name: 'machine',
      states: {
        S.a: hisma.State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: hisma.State(
          etm: {
            E.backward: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: hisma.Transition(to: S.a),
        T.toB: hisma.Transition(to: S.b),
      },
    );

HismaRouterGenerator<S, E> createRouterGenerator(
  NavigationMachine<S, E, T> machine,
) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(widget: Screen(machine)),
        S.b: PagelessCreator(
          presenter: PresentDialog(() {
            machine.fire(E.backward);
          }),
          rootNavigator: true,
          event: E.backward,
        ),
      },
    );

const title = 'Imperative Fire Arg Test Screen';
const string = 'Hello from Screen';
const integer = 42;
const doubleNum = 3.14;
final object = DateTime(2025);

class Screen extends StatelessWidget {
  const Screen(this.machine, {super.key});
  final hisma.Machine<S, E, T> machine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              child: const Text('Send nothing'),
              onPressed: () {
                machine.fire(E.forward);
              },
            ),
            TextButton(
              child: const Text('Send String'),
              onPressed: () {
                machine.fire(E.forward, arg: string);
              },
            ),
            TextButton(
              child: const Text('Send int'),
              onPressed: () {
                machine.fire(E.forward, arg: integer);
              },
            ),
            TextButton(
              child: const Text('Send double'),
              onPressed: () {
                machine.fire(E.forward, arg: doubleNum);
              },
            ),
            TextButton(
              child: const Text('Send Object'),
              onPressed: () {
                machine.fire(E.forward, arg: object);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PresentDialog implements Presenter<void> {
  PresentDialog(this.goBack);
  void Function() goBack;

  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<DateTime> close,
    required dynamic fireArg,
  }) =>
      showDialog<void>(
        useRootNavigator: rootNavigator,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Simple AlertDialog'),
            content: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello'),
                  Text('Fire arg: $fireArg'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Backward'),
                onPressed: () {
                  goBack();
                },
              ),
            ],
          );
        },
      );
}

class ImperativeFireArgApp extends StatelessWidget {
  ImperativeFireArgApp({super.key, required this.machine});
  final NavigationMachine<S, E, T> machine;
  late final gen = createRouterGenerator(machine);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}
