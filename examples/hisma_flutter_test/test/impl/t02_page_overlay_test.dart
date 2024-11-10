import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/simple_machine.dart';
import 'package:hisma_flutter_test/t02_page_overlay.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../aux/aux.dart';

void main() {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
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

  for (var i = 0; i < machine.states.length; i++) {
    await check(machine, tester, E.self, act: trigger);
    await check(machine, tester, E.forward, act: trigger);

    final presentation = app.generator.mapping[machine.activeStateId];
    final overlay = presentation is PageCreator && presentation.overlay;
    if (overlay) {
      await check(machine, tester, E.back, act: Act.back);
    } else {
      await check(machine, tester, E.back, act: trigger);
    }

    await check(machine, tester, E.self, act: trigger);

    // presentation = app.generator.mapping[machine.activeStateId];
    // overlay = presentation is PageCreator && presentation.overlay;
    // if (overlay) {
    //   await check(machine, tester, E.back, act: Act.back);
    // } else {
    await check(machine, tester, E.back, act: trigger);
    // }

    await check(machine, tester, E.self, act: trigger);
    await check(machine, tester, E.forward, act: trigger);
    await check(machine, tester, E.self, act: trigger);
    await check(machine, tester, E.forward, act: trigger);
  }
}
