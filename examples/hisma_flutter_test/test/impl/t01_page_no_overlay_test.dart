import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/simple_machine.dart';
// import 'package:hisma/hisma.dart';
import 'package:hisma_flutter_test/t01_page_no_overlay.dart';
// import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../aux/aux.dart';

void main() {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'no overlay test with direct fire',
    (tester) async {
      await checkAllStates(tester, act: Act.fire);
    },
  );
  testWidgets(
    'no overlay test with taps',
    (tester) async {
      await checkAllStates(tester, act: Act.tap);
    },
  );
}

Future<void> checkAllStates(
  WidgetTester tester, {
  required Act act,
}) async {
  final machine = createSimpleMachine();
  await machine.start();
  await tester.pumpWidget(NoOverlayApp(machine));
  checkTitle(machine);

  for (var i = 0; i < machine.states.length; i++) {
    await check(machine, tester, E.self, act: act);
    await check(machine, tester, E.forward, act: act);
    await check(machine, tester, E.back, act: act);
    await check(machine, tester, E.self, act: act);
    await check(machine, tester, E.back, act: act);
    await check(machine, tester, E.self, act: act);
    await check(machine, tester, E.forward, act: act);
    await check(machine, tester, E.self, act: act);
    await check(machine, tester, E.forward, act: act);
  }
}
