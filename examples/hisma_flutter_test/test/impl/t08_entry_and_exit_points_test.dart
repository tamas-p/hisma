import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/t08_entry_and_exit_points.dart';
import 'package:hisma_flutter_test/ui.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../aux/aux.dart';

Future<void> main() async {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    (m) => ConsoleMonitor(m),
  ];
  // auxInitLogging();
  testWidgets(
    'Modeless test',
    (tester) async {
      final machine = createMachine();
      await machine.start();
      final app = EntryExitApp(machine: machine, rootNavigator: false);

      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      checkTitle(machine);

      final cp = Checker(
        tester: tester,
        act: Act.tap,
        machine: machine,
        mapping: app.gen.mapping,
      );

      final cc = Checker(
        tester: tester,
        act: Act.tap,
        machine: machine.find<SC, EC, TC>(childMachineName),
        mapping: app.gen.mapping,
      );

      await cp.check(E.forward);

      await cc.check(EC.forward);
      await cc.check(EC.forward);
      await cc.check(EC.forward);
      await cc.check(EC.forward);
      // TODO: When hot reload when machine is on PagelessCreator it throws
      // LateError (LateInitializationError: Field '_previousPages@95086382'
      // has not been initialized.)
      await cc.check(EC.forward);
      // print('Finished');
    },
    skip: false,
  );

  testWidgets(
    'Modeless test 2',
    (tester) async {
      final machine = createMachine();
      await machine.start();
      final app = EntryExitApp(machine: machine, rootNavigator: false);

      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      checkTitle(machine);

      await check(tester, machine, machine, E.forward, S.b);

      final childMachine = machine.find<SC, EC, TC>(childMachineName);
      await check(tester, machine, childMachine, EC.forward, SC.b);
      await check(tester, machine, childMachine, EC.forward, SC.c);
      await check(tester, machine, childMachine, EC.exit1, null);

      await check(tester, machine, machine, E.forward, S.a);
      await check(tester, machine, machine, E.fwd1, S.b);
      await check(tester, machine, childMachine, EC.forward, SC.b);
      await check(tester, machine, childMachine, EC.forward, SC.c);
      await check(tester, machine, childMachine, EC.exit1, null);

      await check(tester, machine, machine, E.forward, S.a);
    },
    skip: false,
  );
}

Future<void> check<S, E, T>(
  WidgetTester tester,
  StateMachineWithChangeNotifier<S, E, T> parentMachine,
  StateMachineWithChangeNotifier<S, E, T> machine,
  E event,
  S? after,
) async {
  await action(machine, tester, event);
  expect(machine.activeStateId, after);
  checkTitle(parentMachine);
}
