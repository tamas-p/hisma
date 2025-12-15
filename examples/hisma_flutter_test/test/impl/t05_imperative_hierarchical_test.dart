import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t05_imperative_hierarchical.dart';
import 'package:hisma_flutter_test/ui.dart';

import '../aux/aux.dart';
import 't04_imperative_test.dart';

Future<void> main() async {
  // Machine.monitorCreators = [
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
  group('Android back button tests', () {
    testWidgets(
      'Imperative hierarchical test with back button, rootNavigator: false',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
        await testBackButton(tester: tester, rootNavigator: false);
      },
    );
    testWidgets(
      'Imperative hierarchical test with back button, rootNavigator: true',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
        await testBackButton(tester: tester, rootNavigator: true);
      },
    );
  });
}

Future<void> testBackButton({
  required WidgetTester tester,
  required bool rootNavigator,
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

  final root = Checker<S, E, T>(
    tester: tester,
    act: Act.tap,
    machine: machine,
    mapping: app.gen.mapping,
  );

  await root.check(E.forward); // a -> b
  await root.check(E.forward); // b -> c
  await root.check(E.forward); // c -> d
  await root.check(E.forward); // d -> e
  await root.check(E.forward); // e -> f
  await root.check(E.forward); // f -> g
  await root.check(E.forward); // g -> h
  await root.check(E.forward); // h -> i
  await root.check(E.forward); // i -> j
  await root.check(E.forward); // j -> k
  expect(machine.activeStateId, S.k);
  checkTitle(machine);

  final childMachine = machine.find<S, E, T>(getMachineName<S>('root', S.k));
  final k = Checker<S, E, T>(
    tester: tester,
    act: Act.tap,
    machine: childMachine,
    mapping: app.gen.mapping,
  );

  await k.check(E.forward); // a -> b
  await k.check(E.forward); // b -> c
  expect(childMachine.activeStateId, S.c);
  checkTitle(childMachine);

  // Now we go back in the root machine which should close the child machine.
  await root.check(E.back); // k-> j
  expect(machine.activeStateId, S.j);
  checkTitle(machine);

  // Here we test that the back button was dispatched correctly to the
  // active root machine.
  await root.checkBackButton(); // j -> i
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
