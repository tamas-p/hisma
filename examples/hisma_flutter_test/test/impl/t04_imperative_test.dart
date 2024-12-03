import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t04_imperative_simple.dart';

import '../../test/aux/aux.dart';

Future<void> main() async {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  group('Imperative test with fire', () {
    testWidgets(
      'rootNavigator: false',
      (tester) async {
        await testAllStates(tester, act: Act.fire, rootNavigator: false);
      },
    );
    testWidgets(
      'rootNavigator: true',
      (tester) async {
        await testAllStates(tester, act: Act.fire, rootNavigator: true);
      },
    );
    group('Imperative test with tap', () {
      testWidgets(
        'rootNavigator: false',
        (tester) async {
          await testAllStates(tester, act: Act.tap, rootNavigator: false);
        },
      );
      testWidgets(
        'rootNavigator: true',
        (tester) async {
          await testAllStates(tester, act: Act.tap, rootNavigator: true);
        },
      );
    });
  });
}

Future<void> testAllStates(
  WidgetTester tester, {
  required Act act,
  required bool rootNavigator,
}) async {
  final machine = createLongerMachine();
  await machine.start();
  final app = ImperativeApp(machine: machine, rootNavigator: rootNavigator);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await checkMachine(tester, act, machine, app.gen.mapping);
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
  // test: no_state_change
  await c.check(E.self);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: circle_to_page_has_no_imperatives
  // test: imperative_closed
  await c.check(E.forward);

  //------

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: circle_to_imperative
  await c.check(E.jumpI);

  //------

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: circle_to_imperative
  await c.check(E.jumpI);

  //------

  // test: new_presentation_imperative_open
  await c.check(E.forward);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: circle_to_imperative_before_page
  await c.check(E.jumpBP);

  //------

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: circle_to_page_has_imperatives
  await c.check(E.jumpP);

  //------

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_imperative_open
  await c.check(E.forward);
  await c.check(E.forward);
  await c.check(E.forward);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_page_notify
  await c.check(E.jumpP);

  // test: new_presentation_page_notify_overlay
  await c.check(E.back);

  // test: new_presentation_page_notify
  await c.check(E.jumpP);

  // test: no_ui_change
  // await c.check(E.forward, titleToBeChecked: false);

  // test: no_state_change
  // await c.check(E.self, titleToBeChecked: false);

  // test: missing_presentation
  // expect(
  //   c.check(E.forward),
  //   throwsA(isA<AssertionError>()),
  // );
}
