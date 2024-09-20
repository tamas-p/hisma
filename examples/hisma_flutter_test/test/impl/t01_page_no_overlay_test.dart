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
  auxInitLogging();
  testWidgets(
    'no overlay test with direct fire',
    (tester) async {
      await checkAllStates(tester, trigger: Act.fire);
    },
  );
  testWidgets(
    'no overlay test with taps',
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
  await tester.pumpWidget(NoOverlayApp(machine));
  checkTitle(machine);

  for (var i = 0; i < machine.states.length; i++) {
    await check(machine, tester, E.self, fire: trigger);
    await check(machine, tester, E.forward, fire: trigger);
    await check(machine, tester, E.back, fire: trigger);
    await check(machine, tester, E.self, fire: trigger);
    await check(machine, tester, E.back, fire: trigger);
    await check(machine, tester, E.self, fire: trigger);
    await check(machine, tester, E.forward, fire: trigger);
    await check(machine, tester, E.self, fire: trigger);
    await check(machine, tester, E.forward, fire: trigger);
  }
}
