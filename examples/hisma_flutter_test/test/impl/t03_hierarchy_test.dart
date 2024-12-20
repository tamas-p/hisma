import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine_simple.dart';
import 'package:hisma_flutter_test/t03_hierarchical.dart';

import '../aux/aux.dart';

// import '../../test/aux/aux.dart';

void main() {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'overlay test with direct fire',
    (tester) async {
      await testAllStates(tester, act: Act.fire);
    },
  );
  testWidgets(
    'overlay test with taps',
    (tester) async {
      await testAllStates(tester, act: Act.tap);
    },
  );
}

Future<void> testAllStates(
  WidgetTester tester, {
  required Act act,
}) async {
  final machine = createSimpleMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalApp(machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await checkMachine(tester, act, machine, app.generator.mapping);
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

  for (var i = 0; i < machine.states.length; i++) {
    await c.check(E.self, act: act);
    await c.check(E.forward, act: act);

    final presentation = mapping[machine.activeStateId];
    final overlay = presentation is PageCreator && presentation.overlay;
    if (overlay) {
      await c.check(E.back, act: Act.back);
    } else {
      await c.check(E.back, act: act);
    }

    await c.check(E.self, act: act);

    // presentation = mapping[machine.activeStateId];
    // overlay = presentation is PageCreator && presentation.overlay;
    // if (overlay) {
    // await _check(machine, tester, E.back, mapping, act: Act.back);
    // } else {
    await c.check(E.back, act: act);
    // }

    await c.check(E.self, act: act);
    await c.check(E.forward, act: act);
    await c.check(E.self, act: act);
    await c.check(E.forward, act: act);
  }
}
