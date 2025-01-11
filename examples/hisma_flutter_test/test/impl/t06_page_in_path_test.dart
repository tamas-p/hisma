import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/t06_page_in_path.dart';

import '../../test/aux/aux.dart';

Future<void> main() async {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  //   (m) => ConsoleMonitor(m),
  // ];
  // auxInitLogging();
  group('Page in path in child', () {
    testWidgets(
      'Page in path in child test with fire, rootNavigator: false',
      (tester) async {
        await pageInPathInChild(tester, act: Act.fire, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Page in path in child test with fire, rootNavigator: true',
      (tester) async {
        await pageInPathInChild(tester, act: Act.fire, rootNavigator: true);
      },
      skip: false,
    );
    testWidgets(
      'Page in path in child test with tap, rootNavigator: false',
      (tester) async {
        await pageInPathInChild(tester, act: Act.tap, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Page in path child test with tap, rootNavigator: true',
      (tester) async {
        await pageInPathInChild(tester, act: Act.tap, rootNavigator: true);
      },
      // Can not be executed by tap as pageless always on top of child
      // pages effectively making it impossible to tap on buttons in these
      // child pages.
      skip: true,
    );
  });

  group('Page in path in root', () {
    testWidgets(
      'Page in path in root test with fire, rootNavigator: false',
      (tester) async {
        await pageInPathInRoot(tester, act: Act.fire, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Page in path in root test with fire, rootNavigator: true',
      (tester) async {
        await pageInPathInRoot(tester, act: Act.fire, rootNavigator: true);
      },
      skip: false,
    );
    testWidgets(
      'Page in path in root test with tap, rootNavigator: false',
      (tester) async {
        await pageInPathInRoot(tester, act: Act.tap, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Page in path in root test with tap, rootNavigator: true',
      (tester) async {
        await pageInPathInRoot(tester, act: Act.tap, rootNavigator: true);
      },
      skip: false,
    );
  });

  group('Restart in root', () {
    testWidgets(
      'Restart in root test with fire, rootNavigator: false',
      (tester) async {
        await restartInRoot(tester, act: Act.fire, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Restart in root test with fire, rootNavigator: true',
      (tester) async {
        await restartInRoot(tester, act: Act.fire, rootNavigator: true);
      },
      skip: false,
    );
    testWidgets(
      'Restart in root test with tap, rootNavigator: false',
      (tester) async {
        await restartInRoot(tester, act: Act.tap, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Restart in root test with tap, rootNavigator: true',
      (tester) async {
        await restartInRoot(tester, act: Act.tap, rootNavigator: true);
      },
      skip: false,
    );
  });
  group('Restart in child', () {
    testWidgets(
      'Restart in child test with fire, rootNavigator: false',
      (tester) async {
        await restartInChild(tester, act: Act.fire, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Restart in child test with fire, rootNavigator: true',
      (tester) async {
        await restartInChild(tester, act: Act.fire, rootNavigator: true);
      },
      skip: false,
    );
    testWidgets(
      'Restart in child test with tap, rootNavigator: false',
      (tester) async {
        await restartInChild(tester, act: Act.tap, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Restart in child test with tap, rootNavigator: true',
      (tester) async {
        await restartInChild(tester, act: Act.tap, rootNavigator: true);
      },
      skip: false,
    );
  });

  group('Leave state in parent', () {
    testWidgets(
      'Leave state in parent test with fire, rootNavigator: false',
      (tester) async {
        await leaveStateInParent(tester, act: Act.fire, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Leave state in parent test with fire, rootNavigator: true',
      (tester) async {
        await leaveStateInParent(tester, act: Act.fire, rootNavigator: true);
      },
      skip: false,
    );
    testWidgets(
      'Leave state in parent test with tap, rootNavigator: false',
      (tester) async {
        await leaveStateInParent(tester, act: Act.tap, rootNavigator: false);
      },
      skip: false,
    );
    testWidgets(
      'Leave state in parent test with tap, rootNavigator: true',
      (tester) async {
        await leaveStateInParent(tester, act: Act.tap, rootNavigator: true);
      },
      skip: false,
    );
  });
}

class Checker {
  Checker({required this.tester, required this.machine, required this.act});
  WidgetTester tester;
  NavigationMachine<S, E, T> machine;
  Act act;

  Future<void> check(E event, S expected) async {
    await action(machine, tester, event, act: act);
    expect(machine.activeStateId, expected);
    checkTitle(machine);
  }
}

Future<void> pageInPathInChild(
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

Future<void> pageInPathInRoot(
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

  final p = Checker(
    tester: tester,
    act: act,
    machine: machine,
  );

  await p.check(E.forward, S.b);
  await p.check(E.fwdD, S.d);
  await p.check(E.forward, S.e);
  await p.check(E.forward, S.f);
  await p.check(E.forward, S.a);
  await p.check(E.forward, S.b);
}

Future<void> restartInRoot(
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

  final p = Checker(
    tester: tester,
    act: act,
    machine: machine,
  );

  await p.check(E.forward, S.b);
  await p.check(E.restart, S.a);
  await p.check(E.forward, S.b);
  await p.check(E.fwdD, S.d);
  await p.check(E.forward, S.e);
  await p.check(E.forward, S.f);
  await p.check(E.forward, S.a);
  await p.check(E.forward, S.b);
}

Future<void> restartInChild(
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

  await p.check(E.self, S.c);

  await c1.check(E.forward, S.b);
  // test: restart_in_child_test_root_navigator
  await c1.check(E.forward, S.c);
  await c1.check(E.forward, S.d);
}

Future<void> leaveStateInParent(
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

  await p.check(E.back, S.b);
  await p.check(E.fwdC, S.c);

  await c1.check(E.forward, S.b);
  // test: leave_state_in_parent
  await c1.check(E.forward, S.c);
  await c1.check(E.forward, S.d);
}
