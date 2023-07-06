// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'utils.dart';

enum S { a, b, b1, c, c1 }

enum E { forward, show, backward }

enum T { toA, toB, toB1, toC, toC1 }

final machine = StateMachineWithChangeNotifier<S, E, T>(
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
        E.show: [T.toB1],
      },
      onEntry: getAction(),
    ),
    S.b1: hisma.State(
      etm: {
        E.backward: [T.toB],
      },
    ),
    S.c: hisma.State(
      etm: {
        E.backward: [T.toB],
        E.show: [T.toC1],
      },
      onEntry: getAction(),
    ),
    S.c1: hisma.State(
      etm: {
        E.backward: [T.toC],
      },
    ),
  },
  transitions: {
    T.toA: hisma.Transition(to: S.a),
    T.toB: hisma.Transition(
      to: S.b,
    ),
    T.toB1: hisma.Transition(to: S.b1),
    T.toC: hisma.Transition(to: S.c),
    T.toC1: hisma.Transition(to: S.c1),
  },
);

hisma.Action getAction() => hisma.Action(
      description: 'Print out data passed.',
      action: (machine, dynamic arg) async => print('Arg passed: $arg'),
    );

//------------------------------------------------------------------------------

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScreenA')),
      body: createButtonsFromStates([machine.states[S.a]]),
    );
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScreenB')),
      body: createButtonsFromStates([machine.states[S.b]]),
    );
  }
}

Future<bool?> b1(
  DialogCreator<bool, E> dc,
  BuildContext context, {
  void Function(BuildContext)? setContext,
}) =>
    showDialog<bool>(
      useRootNavigator: dc.useRootNavigator,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Simple AlertDialog'),
          content: const Text('Hello'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                dc.close(true);
              },
            ),
          ],
        );
      },
    );

class ScreenC extends StatelessWidget {
  const ScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScreenC')),
      body: createButtonsFromStates([machine.states[S.c]]),
    );
  }
}

Future<DateTime?> c1(DialogCreator<DateTime, E> dc, BuildContext context) =>
    showDatePicker(
      useRootNavigator: dc.useRootNavigator,
      context: context,
      firstDate: DateTime(2021),
      initialDate: DateTime.now(),
      currentDate: DateTime.now(),
      lastDate: DateTime(2028),
    );

//------------------------------------------------------------------------------

final hismaRouterGenerator = HismaRouterGenerator<S, E>(
  machine: machine,
  mapping: {
    S.a: MaterialPageCreator<void, S, E>(widget: const ScreenA()),
    S.b: MaterialPageCreator<void, S, E>(
      widget: const ScreenB(),
      event: E.backward,
    ),
    S.b1: DialogCreator(show: b1, event: E.backward, useRootNavigator: true),
    S.c: MaterialPageCreator<void, S, E>(
      widget: const ScreenC(),
      event: E.backward,
      overlay: true,
    ),
    S.c1: DialogCreator(show: c1, event: E.backward, useRootNavigator: true),
  },
);

//------------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: hismaRouterGenerator.routerDelegate,
      routeInformationParser: hismaRouterGenerator.routeInformationParser,
    );
  }
}

//------------------------------------------------------------------------------

Future<void> main() async {
  hisma.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m),
  ];

  await machine.start();
  runApp(const MyApp());
}
