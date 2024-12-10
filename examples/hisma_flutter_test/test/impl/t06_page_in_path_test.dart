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
      skip: false,
    );
  });
  group('Imperative hierarchical test with tap', () {
    testWidgets(
      'Page in path test with tap, rootNavigator: false',
      (tester) async {
        await testAllStates(tester, act: Act.tap, rootNavigator: false);
      },
      skip: false,
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

class Checker {
  Checker({required this.tester, required this.machine, required this.act});
  WidgetTester tester;
  StateMachineWithChangeNotifier<S, E, T> machine;
  Act act;

  Future<void> check(E event, S expected) async {
    await action(machine, tester, event, act: act);
    expect(machine.activeStateId, expected);
    checkTitle(machine);
  }
}

Future<void> checkMachine(
  WidgetTester tester,
  Act act,
  StateMachineWithChangeNotifier<S, E, T> machine,
  Map<S, Presentation> mapping,
) async {
  final p = Checker(
    tester: tester,
    act: act,
    machine: machine,
  );

  final child1Machine = machine.find<S, E, T>(child1);
  final c1 = Checker(
    tester: tester,
    act: act,
    machine: child1Machine,
  );

  await p.check(E.forward, S.b);
  await p.check(E.fwdC, S.c);

  await c1.check(E.forward, S.b);
  await c1.check(E.forward, S.c);
  await c1.check(E.forward, S.d);
  await c1.check(E.forward, S.e);
  await c1.check(E.forward, S.f);
  await c1.check(E.forward, S.g);

  await c1.check(E.forward, S.a);
  await c1.check(E.forward, S.b);
  // test: page_in_path
  await c1.check(E.forward, S.c);
}
