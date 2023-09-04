import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart' as hf;

final machine = createMachine();

Future<void> main() async {
  await machine.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // final hf.StateMachineWithChangeNotifier<S, void, void> machine;

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
    // TODO: implement popRoute
    throw UnimplementedError();
  }

  @override
  Future<void> setNewRoutePath(bool configuration) {
    // TODO: implement setNewRoutePath
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

hf.StateMachineWithChangeNotifier<S, void, void> createMachine() =>
    hf.StateMachineWithChangeNotifier(
      name: 'simple',
      initialStateId: S.a,
      states: {
        S.a: h.State(),
      },
      transitions: {},
    );

hf.HismaRouterGenerator<S, void> createRouterGenerator(
  hf.StateMachineWithChangeNotifier<S, void, void> machine,
) =>
    hf.HismaRouterGenerator<S, void>(
      machine: machine,
      mapping: {
        S.a: hf.MaterialPageCreator<void, S, void>(widget: const ScreenA()),
      },
    );

//------------------------------------------------------------------------------
