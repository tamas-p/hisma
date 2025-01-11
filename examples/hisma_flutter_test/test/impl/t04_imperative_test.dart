import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t04_imperative_simple.dart';
import 'package:hisma_flutter_test/ui.dart';

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

  group('Assertion tests', () {
    Future<void> testUiClosedNoCircleBackButton({
      required WidgetTester tester,
      required bool rootNavigator,
      required Act act,
    }) async {
      final machine = createLongerMachine();
      await machine.start();
      final app = ImperativeApp(machine: machine, rootNavigator: rootNavigator);
      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      checkTitle(machine);
      final c = Checker<S, E, T>(
        tester: tester,
        act: act,
        machine: machine,
        mapping: app.gen.mapping,
      );

      await c.check(E.back);
      final backButton = find.byType(BackButton);
      await expectThrowInFuture<AssertionError>(
        () async {
          // test: assert_on_no_circle
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        },
        assertText: 'the path is not forming a circle',
      );
    }

    group('Assertion tests, UiClosedNoCircle, BackButton', () {
      testWidgets(
          'Assertion tests, UiClosedNoCircle, BackButton, '
          'rootNavigator: false, act: fire', (tester) async {
        await testUiClosedNoCircleBackButton(
          tester: tester,
          rootNavigator: false,
          act: Act.fire,
        );
      });
      testWidgets(
          'Assertion tests, UiClosedNoCircle, BackButton, '
          'rootNavigator: true, act: fire', (tester) async {
        await testUiClosedNoCircleBackButton(
          tester: tester,
          rootNavigator: true,
          act: Act.fire,
        );
      });
      testWidgets(
          'Assertion tests, UiClosedNoCircle, BackButton, '
          'rootNavigator: false, act: tap', (tester) async {
        await testUiClosedNoCircleBackButton(
          tester: tester,
          rootNavigator: false,
          act: Act.tap,
        );
      });
      testWidgets(
          'Assertion tests, UiClosedNoCircle, BackButton, '
          'rootNavigator: true, act: tap', (tester) async {
        await testUiClosedNoCircleBackButton(
          tester: tester,
          rootNavigator: true,
          act: Act.tap,
        );
      });
    });

    group('Assertion tests, UiClosedNoCircle, click away dialog', () {
      Future<void> testUiClosedNoCircleClickAway({
        required WidgetTester tester,
        required bool rootNavigator,
        required Act act,
      }) async {
        final machine = createLongerMachine();
        await machine.start();
        final app = ImperativeApp(machine: machine, rootNavigator: false);
        await tester.pumpWidget(app);
        expect(machine.activeStateId, machine.initialStateId);
        checkTitle(machine);
        final c = Checker<S, E, T>(
          tester: tester,
          act: Act.tap,
          machine: machine,
          mapping: app.gen.mapping,
        );

        await c.check(E.back);
        await expectThrowInFuture<AssertionError>(() async {
          // test: assert_on_no_circle
          await c.check(E.back); // THIS is where assert will come from.
          await tester.tapAt(const Offset(10, 10));
          await tester.pump();
        });
      }

      testWidgets(
        'Assertion tests, UiClosedNoCircle, click away dialog '
        'rootNavigator: false, act: fire',
        (tester) async {
          await testUiClosedNoCircleClickAway(
            tester: tester,
            rootNavigator: false,
            act: Act.fire,
          );
        },
      );
      testWidgets(
        'Assertion tests, UiClosedNoCircle, click away dialog '
        'rootNavigator: true, act: fire',
        (tester) async {
          await testUiClosedNoCircleClickAway(
            tester: tester,
            rootNavigator: true,
            act: Act.fire,
          );
        },
      );
      testWidgets(
        'Assertion tests, UiClosedNoCircle, click away dialog '
        'rootNavigator: false, act: tap',
        (tester) async {
          await testUiClosedNoCircleClickAway(
            tester: tester,
            rootNavigator: false,
            act: Act.tap,
          );
        },
      );
      testWidgets(
        'Assertion tests, UiClosedNoCircle, click away dialog '
        'rootNavigator: true, act: tap',
        (tester) async {
          await testUiClosedNoCircleClickAway(
            tester: tester,
            rootNavigator: true,
            act: Act.tap,
          );
        },
      );
    });

    group('Assertion tests, missing_presentation', () {
      Future<void> testMissingPresentation({
        required WidgetTester tester,
        required bool rootNavigator,
        required Act act,
      }) async {
        final machine = createLongerMachine();
        await machine.start();
        final app = ImperativeApp(machine: machine, rootNavigator: false);
        await tester.pumpWidget(app);
        expect(machine.activeStateId, machine.initialStateId);
        checkTitle(machine);
        final c = Checker<S, E, T>(
          tester: tester,
          act: Act.tap,
          machine: machine,
          mapping: app.gen.mapping,
        );

        await c.check(E.back);
        await c.check(E.jumpP);
        await c.check(E.self);
        await expectThrowInFuture<AssertionError>(
          () async {
            // test: missing_presentation
            await action(machine, tester, E.fwdToException);
          },
          assertText: 'Presentation is not handled for',
        );
      }

      testWidgets(
          'Assertion tests, missing_presentation '
          'rootNavigator: false, act: fire', (tester) async {
        await testMissingPresentation(
          tester: tester,
          rootNavigator: false,
          act: Act.fire,
        );
      });
      testWidgets(
          'Assertion tests, missing_presentation '
          'rootNavigator: true, act: fire', (tester) async {
        await testMissingPresentation(
          tester: tester,
          rootNavigator: true,
          act: Act.fire,
        );
      });
      testWidgets(
          'Assertion tests, missing_presentation '
          'rootNavigator: false, act: tap', (tester) async {
        await testMissingPresentation(
          tester: tester,
          rootNavigator: false,
          act: Act.tap,
        );
      });
      testWidgets(
          'Assertion tests, missing_presentation '
          'rootNavigator: true, act: tap', (tester) async {
        await testMissingPresentation(
          tester: tester,
          rootNavigator: true,
          act: Act.tap,
        );
      });
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
  NavigationMachine<S, E, T> machine,
  Map<S, Presentation> mapping,
) async {
  final c = Checker<S, E, T>(
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

  // test: no_state_change
  await c.check(E.self);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: circle_to_page_has_no_imperatives
  // test: imperative_closed
  await c.check(E.forward);

  // test: no_state_change
  await c.check(E.self);

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

  // test: no_state_change
  await c.check(E.self);

  // test: new_presentation_page_notify_overlay
  await c.check(E.forward);

  // test: new_presentation_page_notify
  await c.check(E.jumpP);

  // test: new_presentation_page_notify_overlay
  await c.check(E.back);

  // test: new_presentation_page_notify
  await c.check(E.jumpP);
  final title = getTitle(machine, machine.activeStateId);

  // test: no_ui_change
  await c.check(E.forward, titleToBeChecked: title);

  await action(machine, tester, E.back, act: Act.fire);
  // test: no_state_change
  await c.check(E.self, titleToBeChecked: title);
}
