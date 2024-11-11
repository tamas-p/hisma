import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t04_imperative_simple.dart';

import '../aux/aux.dart';

void main() {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'StateMachineWithChangeNotifier fire assertion test',
    (tester) async {
      final machine = createLongerMachine();
      await machine.start();
      final app = ImperativeApp(machine);
      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      checkTitle(machine);
    },
  );
}

class ImperativeApp extends StatelessWidget {
  ImperativeApp(this.machine, {super.key});
  late final gen = createImperativeGenerator(machine);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}
