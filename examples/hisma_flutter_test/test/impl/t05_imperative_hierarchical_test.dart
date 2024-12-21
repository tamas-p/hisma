import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t05_imperative_hierarchical.dart';

import '../../test/aux/aux.dart';
import 't04_imperative_test.dart';

Future<void> main() async {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  //   (m) => ConsoleMonitor(m),
  // ];
  // auxInitLogging();
  group('Imperative hierarchical test with fire', () {
    testWidgets(
      'Imperative hierarchical test with fire, rootNavigator: false',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
        await testAllStates(tester, act: Act.fire, rootNavigator: false);
      },
    );
    testWidgets(
      'Imperative hierarchical test with fire, rootNavigator: true',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
        await testAllStates(tester, act: Act.fire, rootNavigator: true);
      },
    );
  });
  group('Imperative hierarchical test with tap', () {
    testWidgets(
      'Imperative hierarchical test with tap, rootNavigator: false',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
        await testAllStates(tester, act: Act.tap, rootNavigator: false);
      },
    );
    testWidgets(
      'Imperative hierarchical test with tap, rootNavigator: true',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
        await testAllStates(tester, act: Act.tap, rootNavigator: true);
      },
      // Cannot be executed by tap as pageless on root is always on top of child
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
  final machine = createLongerMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalImperativeApp(
    machine: machine,
    rootNavigator: rootNavigator,
  );
  final box = ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 1000, minWidth: 1000),
    child: app,
  );
  await tester.pumpWidget(box);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await checkMachine(tester, act, machine, app.gen.mapping);
}
