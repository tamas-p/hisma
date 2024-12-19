import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:logging/logging.dart';

import '../app/layers/machine/auth_machine.dart';
import '../app/layers/routing/auth_routing.dart';
import '../assistance.dart';
import '../firebase_options.dart';

// final log = getLogger('main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initLogging();

  hisma.StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine, host: '192.168.122.1'),
    // (machine) => ActiveStateMonitor(machine, printer: log.info),
    (machine) => ConsoleMonitor(machine),
  ];

  await authMachine.start();

  runApp(const MyApp());
}

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger(fbAuthHismaExample).level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // if (record.loggerName == hisma.StateMachine.loggerName) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
    // }
  });
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
      routerDelegate: appRouter.routerDelegate,
    );
  }
}
