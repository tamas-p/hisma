// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'ui.dart';

Future<void> main() async {
  hisma.Machine.monitorCreators = [
    (m) => VisualMonitor(m),
  ];

  final machine = createReturnValueMachine();
  await machine.start();
  runApp(ReturnValueApp(machine: machine));
}

enum Returned { okFromOverlay, okFromDialog }

enum S { a, b, c, d }

enum E { forward, backward }

enum T { toA, toB, backToB, toC, backToC, toD }

NavigationMachine<S, E, T> createReturnValueMachine() =>
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
            E.forward: [T.toC],
            E.backward: [T.toA],
          },
        ),
        S.c: hisma.State(
          etm: {
            E.forward: [T.toD],
            E.backward: [T.backToB],
          },
        ),
        S.d: hisma.State(
          etm: {
            E.backward: [T.backToC],
          },
        ),
      },
      transitions: {
        T.toA: hisma.Transition(to: S.a, onAction: createAction<Returned>()),
        T.toB: hisma.Transition(to: S.b),
        T.backToB:
            hisma.Transition(to: S.b, onAction: createAction<Returned>()),
        T.toC: hisma.Transition(to: S.c),
        T.backToC:
            hisma.Transition(to: S.c, onAction: createAction<DateTime>()),
        T.toD: hisma.Transition(to: S.d),
      },
    );

hisma.Action createAction<T>() => hisma.Action(
      description: 'Print out returned value.',
      action: (machine, dynamic arg) {
        assert(arg is T?);
        machine.data = arg;
      },
    );

class PresentDialog implements Presenter<Returned?> {
  PresentDialog(this.goForward);
  void Function() goForward;

  @override
  Future<Returned?> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<Returned?> close,
    required dynamic arg,
  }) =>
      showDialog<Returned>(
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
                  Text('Fire arg: $arg'),
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
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(Returned.okFromDialog);
                },
              ),
              TextButton(
                child: const Text('Forward'),
                onPressed: () {
                  goForward();
                },
              ),
            ],
          );
        },
      );
}

class PresentDatePicker implements Presenter<DateTime?> {
  @override
  Future<DateTime?> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<DateTime> close,
    required dynamic arg,
  }) =>
      showDatePicker(
        useRootNavigator: rootNavigator,
        context: context,
        firstDate: DateTime(2021),
        initialDate: DateTime.now(),
        currentDate: DateTime.now(),
        lastDate: DateTime(2028),
      );
}

HismaRouterGenerator<S, E> createRouterGenerator(
  NavigationMachine<S, E, T> machine,
) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(widget: Screen(machine)),
        S.b: MaterialPageCreator<E, void>(
          widget: Screen(
            machine,
            extra: Builder(
              builder: (context) {
                return TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(Returned.okFromOverlay);
                  },
                );
              },
            ),
          ),
          overlay: true,
          event: E.backward,
        ),
        S.c: PagelessCreator(
          presenter: PresentDialog(() {
            machine.fire(E.forward);
          }),
          rootNavigator: true,
          event: E.backward,
        ),
        S.d: PagelessCreator(
          presenter: PresentDatePicker(),
          rootNavigator: true,
          event: E.backward,
        ),
      },
    );

class ReturnValueApp extends StatelessWidget {
  ReturnValueApp({
    required this.machine,
    super.key,
  });
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
