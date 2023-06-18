import 'dart:math';

import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine.dart';
import 'package:hisma_flutter_test/main.dart';
import 'package:hisma_flutter_test/ui.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:logging/logging.dart';

import '../../../examples/hisma_flutter_test/test/aux/aux.dart';

const _loggerName = 'FlutterTest';
final Logger _log = Logger(_loggerName);

Future<void> action(
  StateMachineWithChangeNotifier<S, E, T> machine,
  WidgetTester tester,
  E event, {
  bool fire = false,
}) async {
  if (fire) {
    await machine.fire(event);
    // We need this extra pumpAndSettle as pageless routes are created in a
    // subsequent frame by Future.delayed.
    await tester.pumpAndSettle();
  } else {
    await tester.tap(find.text('$event').last);
  }
  await tester.pumpAndSettle();
}

Future<void> checkAll(
  StateMachineWithChangeNotifier<S, E, T> machine,
  WidgetTester tester,
  S previous,
  S current,
  S next, {
  bool fire = false,
}) async {
  await action(machine, tester, E.back, fire: fire);
  checkTitle(machine, previous);

  await action(machine, tester, E.forward, fire: fire);
  checkTitle(machine, current);

  await action(machine, tester, E.self, fire: fire);
  checkTitle(machine, current);

  await action(machine, tester, E.forward, fire: fire);
  checkTitle(machine, next);
}

Future<void> testIt({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required WidgetTester tester,
  required bool fire,
}) async {
  await checkAll(machine, tester, S.n, S.a, S.b, fire: fire);
  await checkAll(machine, tester, S.a, S.b, S.c, fire: fire);
  await checkAll(machine, tester, S.b, S.c, S.d, fire: fire);
  await checkAll(machine, tester, S.c, S.d, S.e, fire: fire);
  await checkAll(machine, tester, S.d, S.e, S.f, fire: fire);
  await checkAll(machine, tester, S.e, S.f, S.g, fire: fire);
  await checkAll(machine, tester, S.f, S.g, S.h, fire: fire);
  await checkAll(machine, tester, S.g, S.h, S.i, fire: fire);
  await checkAll(machine, tester, S.h, S.i, S.j, fire: fire);

  await checkAll(machine, tester, S.i, S.j, S.k, fire: fire);
  await checkAll(machine, tester, S.j, S.k, S.l, fire: fire);
  await checkAll(machine, tester, S.k, S.l, S.m, fire: fire);
  await checkAll(machine, tester, S.l, S.m, S.n, fire: fire);
  await checkAll(machine, tester, S.m, S.n, S.a, fire: fire);
}

void main() {
  auxInitLogging();

  const useRootNavigator = false;
  HistoryLevel? historyLevel;

  /// We are testing
  /// - State change initiated from
  ///   - UI
  ///   - firing event
  /// - Self transition -> no change
  /// - Different route types
  ///   - Paged route
  ///   - Overlay paged route
  ///     - back by clicking on back button
  ///   - Pageless route
  ///     - click on OK etc.
  ///     - dispose buy clicking on edge
  ///     - manage return value
  ///     - No fire if state already changed: SnackBar
  /// - Circles
  ///   - one hop circle
  ///   - multiple hop circle with only paged routes
  ///   - multiple hop circle with paged and overlay paged routes
  ///   - multiple hop circle with paged and overlay paged and pageless routes
  /// - History states
  ///   - Simple
  ///   - Switch from one history state to another one
  ///
  testWidgets(
    'UI initiated state change.',
    (tester) async {
      final machine = createMachine(name: 'root', historyLevel: historyLevel);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: machine, useRootNavigator: useRootNavigator),
      );

      checkTitle(machine, S.a);
      await testIt(machine: machine, tester: tester, fire: false);
    },
    skip: false,
  );

  testWidgets(
    'Machine event fired initiated state change.',
    (tester) async {
      final machine =
          createMachine(name: 'root', historyLevel: HistoryLevel.deep);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: machine, useRootNavigator: true),
      );

      checkTitle(machine, S.a);
      await testIt(machine: machine, tester: tester, fire: true);
    },
    skip: false,
  );

  testWidgets(
    'hisma_flutter test',
    (tester) async {
      final sm = createMachine(name: 'root', historyLevel: historyLevel);
      await sm.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: sm, useRootNavigator: useRootNavigator),
      );
      // Verify that the title of the home page is displayed.
      expect(find.text(getTitle(sm, sm.activeStateId)), findsOneWidget);

      await sm.fire(E.forward);
      await tester.pumpAndSettle();

      // Verify that the title of the home page is displayed.
      expect(find.text(getTitle(sm, sm.activeStateId)), findsOneWidget);
      await tester.pumpAndSettle();
    },
    skip: false,
  );

  group(
    'description',
    () {
      testWidgets('''
Testing that pageless routes are managed well in case of a root machine.
''', (tester) async {
        const machineName = 'root';
        final sm = createMachine(name: machineName, historyLevel: historyLevel);
        await sm.start();
        // Build our app and trigger a frame.
        await tester.pumpWidget(
          MyApp(machine: sm, useRootNavigator: useRootNavigator),
        );
        checkTitle(sm);

        await sm.fire(E.jumpBack);
        expect(sm.activeStateId, S.l);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await tester.tap(find.text('${E.jumpBack}').last, warnIfMissed: false);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>(machineName).fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>(machineName).fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>(machineName).fire(E.jumpBack);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>(machineName).fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>(machineName).fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);
      });

      testWidgets('''
Testing that pageless routes are managed well in case of a child machine.
''', (tester) async {
        const machineName = 'root';
        final sm = createMachine(name: machineName);
        await sm.start();
        // Build our app and trigger a frame.
        await tester.pumpWidget(
          MyApp(machine: sm, useRootNavigator: useRootNavigator),
        );
        checkTitle(sm);

        await sm.fire(E.jumpBack);
        expect(sm.activeStateId, S.l);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await tester.tap(find.text('${E.jumpBack}').last, warnIfMissed: false);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('$machineName/S.l').fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('$machineName/S.l').fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('$machineName/S.l').fire(E.jumpBack);
        await tester.pumpAndSettle();
        checkTitle(sm);

        // This
        await sm.find<S, E, T>('$machineName/S.l').fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('$machineName/S.l').fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);
      });
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test - 0.',
    (tester) async {
      StateMachine.monitorCreators = [
        (m) => VisualMonitor(m, host: '192.168.122.1'),
      ];
      final machine = createMachine(name: 'root', historyLevel: historyLevel);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: machine, useRootNavigator: useRootNavigator),
      );

      final mt = MachineTester(tester, machine);

      await mt.tap(E.jumpBack);
      await mt.tap(E.forward);
      await mt.tap(E.forward);
      await mt.tap(E.forward);
      await mt.tap(E.forward);

      await mt.fire(E.forward, 'root');
      await mt.tap(E.jump);

      await mt.tap(E.jumpBack);

      await mt.tap(E.forward);
      await mt.tap(E.self);
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test - 01.',
    (tester) async {
      final machine = createMachine(name: 'root', historyLevel: historyLevel);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: machine, useRootNavigator: useRootNavigator),
      );

      final mt = MachineTester(tester, machine);

      await mt.tap(E.jumpBack);
      await mt.tap(E.forward);
      await mt.tap(E.forward);
      await mt.tap(E.forward);

      await mt.fire(E.jump, 'root');
      await mt.tap(E.jumpBack);

      await mt.tap(E.forward);
      await mt.tap(E.self);
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test - 3.',
    (tester) async {
      final machine = createMachine(name: 'root', historyLevel: historyLevel);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: machine, useRootNavigator: useRootNavigator),
      );

      final mt = MachineTester(tester, machine);

      await mt.tap(E.jumpBack);
      await mt.tap(E.jumpBack);

      await mt.fire(E.back, 'root/S.l');

      await mt.fire(E.jumpBack, 'root/S.l');
      await mt.tap(E.jumpBack);

      await mt.fire(E.forward, 'root');
      await mt.tap(E.jump);

      await mt.tap(E.jumpBack);

      await mt.tap(E.forward);
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test.',
    (tester) async {
      final machine = createMachine(name: 'root', historyLevel: historyLevel);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MyApp(machine: machine, useRootNavigator: useRootNavigator),
      );

      final mt = MachineTester(tester, machine);

      // await mt.fire(E.self, 'root');
      await mt.tap(E.jumpBack);
      // await mt.fire(E.self, 'root');
      await mt.fire(E.forward, 'root/S.l');
      // await mt.tap(E.self);
      // await mt.tap(E.self);
      await mt.fire(E.jumpBack, 'root/S.l');
      await mt.tap(E.jumpBack);
      // await mt.tap(E.self);
      await mt.tap(E.forward);
      await mt.tap(E.back);
      await mt.tap(E.forward);
      // await mt.fire(E.self, 'root');
      await mt.tap(E.jumpBack);
      await mt.fire(E.jumpBack, 'root/S.l');
      await mt.tap(E.jumpBack);
      // await mt.fire(E.self, 'root/S.l');

      await mt.fire(E.forward, 'root');
      await mt.tap(E.jump);

      // await mt.tap(E.self);
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.forward);
      // await mt.fire(E.back, 'root');
      // await mt.fire(E.back, 'root');
      // await mt.fire(E.forward, 'root');
      // await mt.fire(E.jump, 'root');
      // await mt.fire(E.forward, 'root');
      // await mt.fire(E.forward, 'root');
      // await mt.fire(E.forward, 'root');
      // await mt.fire(E.jumpBack, 'root');
      // await mt.fire(E.forward, 'root');
      // await mt.tap(E.back);
      // await mt.tap(E.jump);

      await mt.tap(E.jumpBack);

      // await mt.fire(E.jumpBack, 'root');
      await mt.tap(E.forward);

      // await mt.tap(E.jumpBack);
      // await mt.fire(E.back, 'root');
      // await mt.fire(E.jump, 'root');
      // await mt.tap(E.self);
      // await mt.tap(E.self);
      // await mt.tap(E.forward);

      // await mt.tap(E.forward);
      // await mt.tap(E.back);
      // await mt.fire(E.back, 'root');
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.forward);
    },
    skip: false,
  );

  testWidgets(
    "Looking up a deactivated widget's ancestor is unsafe",
    (tester) async {
      final machine =
          createMachine(name: 'root', historyLevel: HistoryLevel.deep);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine: machine, useRootNavigator: true));
      final mt = MachineTester(tester, machine);

      // await mt.fire(E.jump, 'root');
      // await mt.tap(E.back);
      // await mt.fire(E.jumpBack, 'root');
      // await mt.tap(E.forward);
      // await mt.tap(E.self);
      // await mt.tap(E.self);
      // await mt.fire(E.jump, 'root');
      // await mt.fire(E.self, 'root');
      // await mt.tap(E.self);
      // await mt.tap(E.self);

      // await mt.fire(E.forward, 'root');
      // await mt.fire(E.self, 'root');
      // await mt.tap(E.forward);
      // await mt.tap(E.forward);
      // await mt.tap(E.jump);
      // await mt.tap(E.back);
      // await mt.fire(E.jumpBack, 'root');
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.back);
      // await mt.fire(E.self, 'root/S.k/S.l');
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.forward);
      // await mt.tap(E.forward);
      // await mt.tap(E.self);
      // await mt.fire(E.jumpBack, 'root');
      // await mt.tap(E.back);
      // await mt.fire(E.jumpBack, 'root');
      // await mt.fire(E.self, 'root');
      // await mt.fire(E.back, 'root');
      // await mt.fire(E.self, 'root');
      // await mt.tap(E.forward);
      // await mt.fire(E.back, 'root');
      // await mt.fire(E.self, 'root');
      // await mt.tap(E.jumpBack);

      await mt.tap(E.back);

      await mt.tap(E.jumpBack);
      await mt.tap(E.jumpBack);
      await mt.fire(E.forward, 'root/S.k');
      await mt.fire(E.back, 'root');
    },
    skip: false,
  );

  testWidgets(
    'Expected: exactly one matching node in the widget tree',
    (tester) async {
      final machine = createMachine(name: 'root', historyLevel: historyLevel);
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine: machine, useRootNavigator: true));
      final mt = MachineTester(tester, machine);

      await mt.fire(E.self, 'root');
      await mt.fire(E.jumpBack, 'root');
      await mt.fire(E.jumpBack, 'root/S.l');
      await mt.tap(E.self);
      await mt.tap(E.forward);
      await mt.fire(E.self, 'root');
      await mt.tap(E.forward);
      await mt.tap(E.jumpBack);
      await mt.fire(E.forward, 'root');
      await mt.fire(E.jumpBack, 'root');
      await mt.tap(E.back);
      await mt.backButton();
    },
    skip: false,
  );

  testWidgets(
    'When pageless needs to be popped explicitly when'
    ' becomes inactive its machine.',
    (tester) async {
      final machine = createMachine(name: 'root');
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine: machine, useRootNavigator: true));
      final mt = MachineTester(tester, machine);

      await mt.tap(E.back);
      await mt.tap(E.back);
      await mt.tap(E.back);
      await mt.tap(E.back);
      await mt.tap(E.back);

      // Here when we are back to S.l/S.a the S.l/S.m dialog was still shown.
      await mt.fire(E.self, 'root');

      await mt.fire(E.forward, 'root/S.l');
      await mt.fire(E.jumpBack, 'root/S.l');
    },
    skip: true,
  );
  testWidgets(
    'original debug.',
    (tester) async {
      final machine = createMachine(name: 'root');
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine: machine, useRootNavigator: true));
      final mt = MachineTester(tester, machine);

      await mt.fire(E.forward, 'root');
      await mt.tap(E.jumpBack);
      await mt.tap(E.back);
      await mt.fire(E.forward, 'root');
      await mt.tap(E.back);
      await mt.tap(E.forward);
      await mt.tap(E.jumpBack);
      await mt.tap(E.jumpBack);
      await mt.fire(E.back, 'root');
      await mt.fire(E.forward, 'root/S.k');
      await mt.tap(E.back);
      await mt.fire(E.jumpBack, 'root/S.k');
      // await mt.fire(E.self, 'root/S.k/S.l');
      await mt.tap(E.jumpBack);
      await mt.fire(E.forward, 'root/S.k');
      await mt.fire(E.forward, 'root');

      await mt.tap(E.forward);
      await mt.fire(E.jumpBack, 'root/S.l');
    },
    skip: false,
  );
  testWidgets(
    'shortened debug.',
    (tester) async {
      final machine = createMachine(name: 'root');
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine: machine, useRootNavigator: true));
      final mt = MachineTester(tester, machine);

      // await mt.fire(E.forward, 'root');
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.back);

      await mt.tap(E.jumpBack);
      await mt.fire(E.back, 'root');

      // await mt.fire(E.forward, 'root');
      // await mt.tap(E.forward);
      // await mt.tap(E.jumpBack);
      // await mt.tap(E.jumpBack);
      // await mt.fire(E.back, 'root');
      // await mt.fire(E.forward, 'root/S.k');
      // await mt.tap(E.back);
      // await mt.fire(E.jumpBack, 'root/S.k');
      // await mt.fire(E.self, 'root/S.k/S.l');
      await mt.tap(E.jumpBack);
      await mt.fire(E.forward, 'root/S.k');

      await mt.fire(E.forward, 'root');

      // await mt.tap(E.forward);
      // await mt.fire(E.jumpBack, 'root/S.l');
      // await mt.tap(E.self);
    },
    skip: false,
  );
}

class MachineTester {
  MachineTester(this.tester, this.machine);

  final WidgetTester tester;
  final StateMachine<S, E, T> machine;

  Future<void> fire(E eventId, String machineName) async {
    _log.info('${machine.getActiveStateRecursive()} <fire> $eventId');
    await machine.find<S, E, T>(machineName).fire(eventId);
    await _check();
  }

  Future<void> tap(E eventId) async {
    _log.info('${machine.getActiveStateRecursive()} <tap> $eventId');
    await tester.tap(find.text(eventId.toString()).last, warnIfMissed: false);
    await _check();
  }

  Future<void> backButton() async {
    _log.info('${machine.getActiveStateRecursive()} <backButton>');
    await pageBack(tester);
    await _check();
  }

  Future<void> _check() async {
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    checkTitle(machine);
  }
}
