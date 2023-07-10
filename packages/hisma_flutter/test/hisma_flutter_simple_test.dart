import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

enum S { a, b }

enum E { forward, back }

enum T { toA, toB }

const simpleName = 'simple';

StateMachineWithChangeNotifier<S, E, T> createSimpleMachine() =>
    StateMachineWithChangeNotifier(
      events: E.values,
      name: simpleName,
      initialStateId: S.a,
      states: {
        S.a: hisma.State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: hisma.State(
          etm: {
            E.back: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: hisma.Transition(to: S.a),
        T.toB: hisma.Transition(to: S.b),
      },
    );

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$ScreenA'),
      ),
    );
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$ScreenB'),
      ),
    );
  }
}

HismaRouterGenerator<S, E> createHismaRouterGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine,
) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<void, S, E>(widget: const ScreenA()),
        S.b: MaterialPageCreator<void, S, E>(widget: const ScreenB()),
      },
    );

class MyApp extends StatelessWidget {
  MyApp(StateMachineWithChangeNotifier<S, E, T> machine, {super.key})
      : _routerGenerator = createHismaRouterGenerator(machine);

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

Future<void> main() async {
  testWidgets('hisma_flutter test1', (tester) async {});
  StateMachine.monitorCreators = [
    // (m) => VisualMonitor(m),
    // (m) => ConsoleMonitor(m),
  ];
  // initLogging();
  final simpleMachine = createSimpleMachine();

  testWidgets(
    'description',
    (tester) async {
      await simpleMachine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(simpleMachine));

      // Verify that the title of the home page is displayed.
      expect(find.text('$ScreenA'), findsOneWidget);

      await simpleMachine.fire(E.forward);
      await tester.pumpAndSettle();

      // Verify that the title of the home page is displayed.
      expect(find.text('$ScreenB'), findsOneWidget);
    },
  );
  // print('Waiting...');
  // await Future<void>.delayed(const Duration(hours: 1));
}

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.ALL;
  // Logger(vismaMonitorName).level = Level.INFO;
  Logger('hisma_flutter').level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
}
