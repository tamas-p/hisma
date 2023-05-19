import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine.dart';
import 'package:hisma_flutter_test/main.dart';
import 'package:hisma_flutter_test/ui.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void check(StateMachineWithChangeNotifier<S, E, T> machine, S stateId) {
  expect(machine.activeStateId, stateId);
  expect(find.text(getTitle(machine, stateId)), findsOneWidget);
}

Future<void> tap(
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
  bool dialog = false,
  bool fire = false,
}) async {
  await tap(machine, tester, E.back, fire: fire);
  check(machine, previous);

  // await Future<void>.delayed(const Duration(seconds: 1));

  await tap(machine, tester, E.forward, fire: fire);
  check(machine, current);

  // await Future<void>.delayed(const Duration(seconds: 1));

  if (!dialog) {
    await tap(machine, tester, E.self, fire: fire);
    check(machine, current);
    // await Future<void>.delayed(const Duration(seconds: 1));
  }

  await tap(machine, tester, E.forward, fire: fire);
  check(machine, next);
}

Future<void> testIt({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required WidgetTester tester,
  required bool fire,
}) async {
  await checkAll(machine, tester, S.n, S.a, S.b, fire: fire);
  await checkAll(machine, tester, S.a, S.b, S.c, fire: fire);
  await checkAll(machine, tester, S.b, S.c, S.d, fire: fire);
  await checkAll(machine, tester, S.c, S.d, S.e, dialog: true, fire: fire);
  await checkAll(machine, tester, S.d, S.e, S.f, dialog: true, fire: fire);
  await checkAll(machine, tester, S.e, S.f, S.g, dialog: true, fire: fire);
  await checkAll(machine, tester, S.f, S.g, S.h, fire: fire);
  await checkAll(machine, tester, S.g, S.h, S.i, dialog: true, fire: fire);
  await checkAll(machine, tester, S.h, S.i, S.j, fire: fire);
  // await checkAll(machine, tester, S.i, S.j, S.k, fire: fire);
  // await checkAll(machine, tester, S.j, S.k, S.l, fire: fire);
  // await checkAll(machine, tester, S.k, S.l, S.m, dialog: true, fire: fire);
  // await checkAll(machine, tester, S.l, S.m, S.n, dialog: true, fire: fire);
  // await checkAll(machine, tester, S.m, S.n, S.a, fire: fire);
}

void main() {
  // testWidgets('hisma_flutter test2', (tester) async {});
  // return;

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
      final machine = createMachine('sm');
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine));
      check(machine, S.a);
      await testIt(machine: machine, tester: tester, fire: false);
    },
    skip: false,
  );

  testWidgets(
    'Machine event fired initiated state change.',
    (tester) async {
      StateMachine.monitorCreators = [
        (m) => VisualMonitor(m, host: '192.168.122.1'),
      ];

      final machine = createMachine('sm');
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine));
      check(machine, S.a);
      await testIt(machine: machine, tester: tester, fire: true);
    },
    skip: false,
  );

  testWidgets(
    'hisma_flutter test',
    (tester) async {
      final sm = createMachine('sm');
      await sm.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(sm));

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
        final sm = createMachine('sm');
        await sm.start();
        // Build our app and trigger a frame.
        await tester.pumpWidget(MyApp(sm));
        checkTitle(sm);

        await sm.fire(E.jumpBack);
        expect(sm.activeStateId, S.l);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await tester.tap(find.text('${E.jumpBack}').last, warnIfMissed: false);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm').fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm').fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm').fire(E.jumpBack);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm').fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm').fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);
      });

      testWidgets('''
Testing that pageless routes are managed well in case of a child machine.
''', (tester) async {
        final sm = createMachine('sm');
        await sm.start();
        // Build our app and trigger a frame.
        await tester.pumpWidget(MyApp(sm));
        checkTitle(sm);

        await sm.fire(E.jumpBack);
        expect(sm.activeStateId, S.l);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await tester.tap(find.text('${E.jumpBack}').last, warnIfMissed: false);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm/S.l').fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm/S.l').fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm/S.l').fire(E.jumpBack);
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm/S.l').fire(E.forward);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        checkTitle(sm);

        await sm.find<S, E, T>('sm/S.l').fire(E.jump);
        await tester.pumpAndSettle();
        checkTitle(sm);
      });
    },
    skip: false,
  );
  testWidgets(
    '''
Monkey test.
The purpose of this test to randomly generate events either by tapping on
UI or directly firing events on a randomly selected active machine of the
hierarchical state machine. This allows us finding problems mainly in
hisma_flutter that we missed discovering with regular auto-tests.
    ''',
    (tester) async {
      StateMachine.monitorCreators = [
        // (m) => VisualMonitor(m, host: '192.168.122.1'),
      ];

      final machine = createMachine('sm');
      await machine.start();
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(machine));
      final stateId = machine.activeStateId;
      if (stateId == null) throw AssertionError();
      final state = machine.stateAt(stateId);
      // We have the same events everywhere. No need to update.
      final events = state?.etm.keys;

      for (var i = 0; i < 150000; i++) {
        print(' >>> $i <<<');
        final rnd = Random();
        final randomEvent = events?.toList()[rnd.nextInt(events.length)];
        if (randomEvent == E.jump) {
          if (rnd.nextInt(100) < 70) continue;
        }
        if (randomEvent == null) throw AssertionError();

        print('-------------------------------------------------------');
        if (rnd.nextBool() == true) {
          print(pretty(machine.getActiveStateRecursive()));
          print(
            'tester.tap(find.text($randomEvent).last, warnIfMissed: false);',
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('$randomEvent').last, warnIfMissed: false);
          await tester.pumpAndSettle();
        } else {
          await tester.pumpAndSettle();
          print(pretty(machine.getActiveStateRecursive()));

          print(getActiveMachines(machine).map((e) => e.name));

          final activeMachines = getActiveMachines(machine);
          final rndMachine = activeMachines[rnd.nextInt(activeMachines.length)];

          // await machine.fire(randomEvent);
          print('rndMachine.fire($randomEvent) - ${rndMachine.name}');
          await rndMachine.fire(randomEvent);
          await tester.pumpAndSettle();
        }

        await tester.pumpAndSettle();

        // checkTitle(machine);

        // await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      print('DONE ----------------------------');
    },
    skip: false,
  );
}

void checkTitle(StateMachine<S, E, T> machine) {
  final activeMachines = getActiveMachines(machine);
  print(activeMachines.map((e) => e.name));
  final lm = activeMachines.last;
  final path = '${lm.name}/${lm.activeStateId}';
  print('>>> Title $path.');

  expect(find.text('Title $path.'), findsOneWidget);
}

List<StateMachine<S, E, T>> getActiveMachines(
  StateMachine<S, E, T> machine,
) {
  final list = <StateMachine<S, E, T>>[];
  if (machine.activeStateId != null) {
    list.add(machine);
    final st = machine.states[machine.activeStateId];
    if (st != null && st is State<E, T, S>) {
      if (st.regions.isNotEmpty) {
        assert(st.regions.length == 1);
        list.addAll(
          getActiveMachines(st.regions.first.machine as StateMachine<S, E, T>),
        );
      }
    }
  }
  return list;
}
