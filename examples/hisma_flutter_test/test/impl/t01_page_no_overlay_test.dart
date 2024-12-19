import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/machine_simple.dart';
import 'package:hisma_flutter_test/t01_page_no_overlay.dart';

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
  final app = NoOverlayApp(machine);
  await tester.pumpWidget(NoOverlayApp(machine));
  checkTitle(machine);

  final c = Checker(
    tester: tester,
    act: act,
    machine: machine,
    mapping: app.gen.mapping,
  );

  for (var i = 0; i < machine.states.length; i++) {
    await c.check(E.self);
    await c.check(E.forward);
    await c.check(E.back);
    await c.check(E.self);
    await c.check(E.back);
    await c.check(E.self);
    await c.check(E.forward);
    await c.check(E.self);
    await c.check(E.forward);
  }
}
