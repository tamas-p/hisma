import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:logging/logging.dart';

import 'machine.dart';
import 'routing.dart';

Future<void> main() async {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    // (m) => ConsoleMonitor(m),
  ];
  initLogging();
  final simpleMachine = createMachine('sm');
  await simpleMachine.start();

  runApp(MyApp(simpleMachine));
}

class MyApp extends StatelessWidget {
  MyApp(StateMachineWithChangeNotifier<S, E, T> machine, {super.key})
      : _routerGenerator = createHismaRouterGenerator(machine);

  final HismaRouterGenerator<S, Widget, E> _routerGenerator;

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

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.OFF;
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
