import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:logging/logging.dart';

import 'app/layers/machine/app_machine.dart';
import 'app/layers/router/app_router_provider.dart';

Future<void> main() async {
  initLogging();
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    // (m) => ConsoleMonitor(m),
  ];

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late Future<void> f;
  @override
  void initState() {
    super.initState();
    final sm = ref.read(appMachineProvider);
    f = sm.start();
  }

  @override
  Widget build(BuildContext context) {
    final w = MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: ref.read(appRouterProvider).routerDelegate,
      routeInformationParser:
          ref.read(appRouterProvider).routeInformationParser,
    );

    final fb = FutureBuilder<void>(
      future: f,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return w;
          default:
            return const CircularProgressIndicator();
        }
      },
    );

    return fb;
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
