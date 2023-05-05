// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'utils.dart';

enum S { a, b, b1, b2, c, c1 }

enum E { forward, show, fetch, backward }

enum T { toA, toB, toB1, toB2, toBFromB2, toC, toC1 }

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
        E.fetch: [T.toB2],
      },
      onEntry: getAction(),
    ),
    S.b1: hisma.State(
      etm: {
        E.backward: [T.toB],
      },
    ),
    S.b2: hisma.State(
      etm: {
        E.backward: [T.toBFromB2],
      },
      onEntry: hisma.Action(
        description: 'Fetch weather report.',
        action: (machine, dynamic arg) async {
          Future<void>.delayed(const Duration(seconds: 1), () {
            print('Weather data is fetched.');
            machine.fire(E.backward, arg: 'Sunny weather.');
          });
        },
      ),
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
    T.toB: hisma.Transition(to: S.b),
    T.toB1: hisma.Transition(to: S.b1),
    T.toB2: hisma.Transition(to: S.b2),
    T.toBFromB2: hisma.Transition(
      to: S.b,
      onAction: hisma.Action(
        description: 'Weather info received.',
        action: (machine, dynamic arg) async {
          print('Weather info received: $arg');
        },
      ),
    ),
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
  BuildContext context, {
  void Function(BuildContext)? setContext,
}) =>
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Simple AlertDialog'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Hello'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
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

Future<DateTime?> c1(
  BuildContext context, {
  void Function(BuildContext)? setContext,
}) =>
    showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      initialDate: DateTime.now(),
      currentDate: DateTime.now(),
      lastDate: DateTime(2028),
    );

//------------------------------------------------------------------------------

final hismaRouterGenerator = HismaRouterGenerator<S, Widget, E>(
  machine: machine,
  mapping: {
    S.a: MaterialPageCreator<S>(widget: const ScreenA()),
    S.b: OverlayMaterialPageCreator<S, E>(
      widget: const ScreenB(),
      event: E.backward,
    ),
    S.b1: PagelessCreator(show: b1, event: E.backward),
    S.b2: NoUIChange(),
    S.c: OverlayMaterialPageCreator<S, E>(
      widget: const ScreenC(),
      event: E.backward,
    ),
    S.c1: PagelessCreator(show: c1, event: E.backward),
  },
);

//------------------------------------------------------------------------------

Future<void> main() async {
  hisma.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m),
  ];

  await machine.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: hismaRouterGenerator.routerDelegate,
      routeInformationParser: hismaRouterGenerator.routeInformationParser,
    );
  }
}
