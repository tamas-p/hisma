// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'utils.dart';

Future<void> main() async {
  hisma.Machine.monitorCreators = [
    (m) => VisualMonitor(m),
  ];

  await machine.start();
  runApp(const MyApp());
}

//------------------------------------------------------------------------------

enum S { a, b, c }

enum E { forward, backward }

enum T { toA, toB, toC }

final machine = NavigationMachine<S, E, T>(
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
        E.backward: [T.toB],
      },
    ),
  },
  transitions: {
    T.toA: hisma.Transition(to: S.a),
    T.toB: hisma.Transition(to: S.b),
    T.toC: hisma.Transition(to: S.c),
  },
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

//------------------------------------------------------------------------------

final hismaRouterGenerator = HismaRouterGenerator<S, E>(
  machine: machine,
  mapping: {
    S.a: MaterialPageCreator<E, void>(widget: const ScreenA()),
    S.b: MaterialPageCreator<E, void>(widget: const ScreenB()),
    S.c: MaterialPageCreator<E, void>(widget: const ScreenC()),
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
