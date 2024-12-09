import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/t06_page_in_path.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../../test/aux/aux.dart';

Future<void> main() async {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    (m) => ConsoleMonitor(m),
  ];
  // auxInitLogging();
  group('Page in path test with fire', () {
    testWidgets(
      'Page in path test with fire, rootNavigator: false',
      (tester) async {
        await testAllStates(tester, act: Act.fire, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Page in path test with fire, rootNavigator: true',
      (tester) async {
        await testAllStates(tester, act: Act.fire, rootNavigator: true);
      },
      skip: true,
    );
  });
  group('Imperative hierarchical test with tap', () {
    testWidgets(
      'Page in path test with tap, rootNavigator: false',
      (tester) async {
        await testAllStates(tester, act: Act.tap, rootNavigator: false);
      },
      skip: true,
    );
    testWidgets(
      'Page in path test with tap, rootNavigator: true',
      (tester) async {
        await testAllStates(tester, act: Act.tap, rootNavigator: true);
      },
      // Can not be executed by tap as pageless always on top of child
      // pages effectively making it impossible to tap on buttons in these
      // child pages.
      skip: true,
    );
  });
}

Future<void> testAllStates(
  WidgetTester tester, {
  required bool rootNavigator,
  required Act act,
}) async {
  final machine = createParentMachine();
  await machine.start();
  final app = PageInPathApp(machine: machine, rootNavigator: rootNavigator);
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

  await action(machine, tester, E.forward, act: act);
  expect(machine.activeStateId, S.b);
  checkTitle(machine);

  await action(machine, tester, E.fwdC, act: act);
  expect(machine.activeStateId, S.c);
  checkTitle(machine);

  final child1Machine = machine.find<S, E, T>(child1);
  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.b);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.c);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.d);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.e);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.f);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.g);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.a);
  checkTitle(child1Machine);

  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.b);
  checkTitle(child1Machine);

  // test: page_in_path
  await action(child1Machine, tester, E.forward, act: act);
  expect(child1Machine.activeStateId, S.c);
  checkTitle(child1Machine);
}
