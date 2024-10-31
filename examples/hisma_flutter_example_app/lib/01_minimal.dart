// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum S { a }

enum E { e1 }

enum T { t1 }

final machine = StateMachineWithChangeNotifier<S, E, T>(
  initialStateId: S.a,
  name: 'machine',
  states: {
    S.a: hisma.State(),
  },
  transitions: {},
);

//------------------------------------------------------------------------------

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen')),
    );
  }
}

//------------------------------------------------------------------------------

final hismaRouterGenerator = HismaRouterGenerator<S, E>(
  machine: machine,
  mapping: {S.a: MaterialPageCreator<E, void>(widget: const Screen())},
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
