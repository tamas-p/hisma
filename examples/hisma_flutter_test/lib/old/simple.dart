import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart' as hf;

import '../utility.dart';

final machine = createMachine();

Future<void> main() async {
  initLogging();
  await machine.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // final hf.MachineWithChangeNotifier<S, void, void> machine;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerDelegate: createRouterGenerator(machine).routerDelegate,
    );
  }
}

//------------------------------------------------------------------------------

class MyRouterDelegate extends RouterDelegate<bool> with ChangeNotifier {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('MyRouterDelegate build.');
    return Navigator(
      key: _navigatorKey,
      pages: const [MaterialPage<void>(child: ScreenA())],
      onPopPage: (route, dynamic result) => route.didPop(result),
    );
  }

  @override
  Future<bool> popRoute() {
    throw UnimplementedError();
  }

  @override
  Future<void> setNewRoutePath(bool configuration) {
    throw UnimplementedError();
  }
}

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple'),
      ),
      body: const Text('Simple body.'),
    );
  }
}

//------------------------------------------------------------------------------

enum S { a }

hf.NavigationMachine<S, void, void> createMachine() => hf.NavigationMachine(
      name: 'simple',
      initialStateId: S.a,
      states: {
        S.a: h.State(),
      },
      transitions: {},
    );

hf.HismaRouterGenerator<S, void> createRouterGenerator(
  hf.NavigationMachine<S, void, void> machine,
) =>
    hf.HismaRouterGenerator<S, void>(
      machine: machine,
      mapping: {
        S.a: hf.MaterialPageCreator<void, void>(widget: const ScreenA()),
      },
    );

//------------------------------------------------------------------------------
