import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t04_imperative_simple.dart';

import '../../test/aux/aux.dart';

Future<void> main() async {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'StateMachineWithChangeNotifier fire assertion test',
    (tester) async {
      await testAllStates(tester, act: Act.fire);
      await testAllStates(tester, act: Act.tap);
    },
  );
}

// TODO: delete this poc function
Future<void> poc(WidgetTester tester) async {
  final machine = createLongerMachine();
  await machine.start();
  final app = ImperativeApp(machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await tester.tap(find.text('testMachine0.E.forward'));
  await tester.pump();

  expect(find.text('testMachine0 - S.b'), findsOneWidget);

  await tester.tap(find.text('testMachine0.E.forward').last);
  await tester.pump();

  // await machine.fire(E.forward);
  // print('AFTER');
  // await tester.pump();

  expect(find.text('testMachine0 - S.c'), findsOneWidget);
}

Future<void> testAllStates(
  WidgetTester tester, {
  required Act act,
}) async {
  final machine = createLongerMachine();
  await machine.start();
  final app = ImperativeApp(machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await checkMachine(tester, act, machine, app.gen.mapping);
}

Future<void> checkMachine(
  WidgetTester tester,
  Act act,
  StateMachineWithChangeNotifier<S, E, T> machine,
  Map<S, Presentation> mapping,
) async {
  final c = Checker(
    tester: tester,
    act: act,
    machine: machine,
    mapping: mapping,
    checkMachine: checkMachine,
  );
  // no_state_change
  await c.check(E.self);

  // new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // new_presentation_page_notify
  await c.check(E.forward);

  // new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // new_presentation_page_notify_overlay
  await c.check(E.forward);
}
