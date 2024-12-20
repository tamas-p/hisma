import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine_simple.dart';
import 'package:hisma_flutter_test/t02_page_overlay.dart';

import '../aux/aux.dart';

void main() {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'overlay test with direct fire',
    (tester) async {
      await checkAllStates(tester, trigger: Act.fire);
    },
  );
  testWidgets(
    'overlay test with taps',
    (tester) async {
      await checkAllStates(tester, trigger: Act.tap);
    },
  );
}

Future<void> checkAllStates(
  WidgetTester tester, {
  required Act trigger,
}) async {
  final machine = createSimpleMachine();
  await machine.start();
  final app = OverlayApp(machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  final c = Checker(
    tester: tester,
    act: trigger,
    machine: machine,
    mapping: app.generator.mapping,
  );

  for (var i = 0; i < machine.states.length; i++) {
    await c.check(E.self);
    await c.check(E.forward);

    final presentation = app.generator.mapping[machine.activeStateId];
    final overlay = presentation is PageCreator && presentation.overlay;
    if (overlay) {
      await c.check(E.back, act: Act.back);
    } else {
      await c.check(E.back);
    }

    await c.check(E.self);

    // presentation = app.generator.mapping[machine.activeStateId];
    // overlay = presentation is PageCreator && presentation.overlay;
    // if (overlay) {
    //   await check(E.back, act: Act.back);
    // } else {
    await c.check(E.back);
    // }

    await c.check(E.self);
    await c.check(E.forward);
    await c.check(E.self);
    await c.check(E.forward);
  }
}
