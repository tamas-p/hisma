import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/chain_machine.dart';
import 'package:hisma_flutter_test/machine.dart';
import 'package:hisma_flutter_test/main.dart';
import 'package:hisma_flutter_test/states_events_transitions.dart';
import 'package:hisma_flutter_test/ui.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:logging/logging.dart';

import 'aux/aux.dart';

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
  // auxInitLogging();

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
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );

        await testIt(machine: machine, tester: tester, fire: false);
      });
    },
    skip: false,
  );

  testWidgets(
    'Machine event fired initiated state change.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );

        await testIt(machine: machine, tester: tester, fire: true);
      });
    },
    skip: false,
  );

  testWidgets(
    'hisma_flutter test',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );

        await machine.fire(E.forward);
        await tester.pumpAndSettle();

        // Verify that the title of the home page is displayed.
        expect(
          find.text(getTitle(machine, machine.activeStateId)),
          findsOneWidget,
        );
        await tester.pumpAndSettle();
      });
    },
    skip: false,
  );

  group('Pageless routes.', () {
    testWidgets(
      '''
Testing that pageless routes are managed well in case of a root machine.
''',
      (tester) async {
        const machineName = 'root';
        await multiplier(({
          required HistoryLevel? historyLevel,
          required bool useRootNavigator,
        }) async {
          final machine = await getMachine(
            historyLevel: historyLevel,
            useRootNavigator: useRootNavigator,
            tester: tester,
          );

          await machine.fire(E.jumpBack);
          expect(machine.activeStateId, S.l);
          await tester.pumpAndSettle();
          checkTitle(machine);

          await tester.tap(
            find.text('${E.jumpBack}').last,
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>(machineName).fire(E.forward);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>(machineName).fire(E.jump);
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>(machineName).fire(E.jumpBack);
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>(machineName).fire(E.forward);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>(machineName).fire(E.jump);
          await tester.pumpAndSettle();
          checkTitle(machine);
        });
      },
      skip: false,
    );

    // TODO: FAILS at
    // await tc(historyLevel: null, useRootNavigator: true);
    // await tc(historyLevel: HistoryLevel.shallow, useRootNavigator: true);
    // await tc(historyLevel: HistoryLevel.deep, useRootNavigator: true);
    testWidgets(
      '''
Testing that pageless routes are managed well in case of a child machine.
''',
      (tester) async {
        const machineName = 'root';
        await multiplier(({
          required HistoryLevel? historyLevel,
          required bool useRootNavigator,
        }) async {
          final machine = await getMachine(
            historyLevel: historyLevel,
            useRootNavigator: useRootNavigator,
            tester: tester,
          );

          await machine.fire(E.jumpBack);
          expect(machine.activeStateId, S.l);
          await tester.pumpAndSettle();
          checkTitle(machine);

          await tester.tap(find.text('${E.jumpBack}').last,
              warnIfMissed: false);
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>('$machineName/S.l').fire(E.forward);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>('$machineName/S.l').fire(E.jump);
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>('$machineName/S.l').fire(E.jumpBack);
          await tester.pumpAndSettle();
          checkTitle(machine);

          // This
          await machine.find<S, E, T>('$machineName/S.l').fire(E.forward);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();
          checkTitle(machine);

          await machine.find<S, E, T>('$machineName/S.l').fire(E.jump);
          await tester.pumpAndSettle();
          checkTitle(machine);
        });
      },
      skip: false,
    );
  });

  testWidgets(
    'Machine has not been started test - 0.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
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
      });
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test - 01.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
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
      });
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test - 3.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
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
      });
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
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
      });
    },
    skip: false,
  );

  testWidgets(
    "Looking up a deactivated widget's ancestor is unsafe",
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );
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
      });
    },
    skip: false,
  );

  testWidgets(
    'Expected: exactly one matching node in the widget tree',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );
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
      });
    },
    skip: false,
  );

  // TODO: FAILS at
  // await tc(historyLevel: null, useRootNavigator: true);
  testWidgets(
    'When pageless needs to be popped explicitly when'
    ' becomes inactive its machine.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );
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
      });
    },
    skip: false,
  );
  testWidgets(
    'original debug.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );
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
      });
    },
    skip: false,
  );
  testWidgets(
    'shortened debug.',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );
        final mt = MachineTester(tester, machine);

        await mt.tap(E.jumpBack);
        await mt.fire(E.back, 'root');
        await mt.tap(E.jumpBack);
        await mt.fire(E.forward, 'root/S.k');
        await mt.fire(E.forward, 'root');
      });
    },
    skip: false,
  );
  testWidgets(
    'building Builder(dirty).',
    (tester) async {
      await multiplier(({
        required HistoryLevel? historyLevel,
        required bool useRootNavigator,
      }) async {
        final machine = await getMachine(
          historyLevel: historyLevel,
          useRootNavigator: useRootNavigator,
          tester: tester,
        );
        final mt = MachineTester(tester, machine);
        await mt.tap(E.jumpBack);
        await mt.tap(E.back);
        await mt.tap(E.back);
        await mt.fire(E.forward, 'root');
        await mt.fire(E.back, 'root');
      });
    },
    skip: false,
  );

  group(
    'Multiple pageless builder in _pageMap',
    () {
      testWidgets(
        'AppBar BackButton resulted doubled dialogs.',
        (tester) async {
          await multiplier(({
            required HistoryLevel? historyLevel,
            required bool useRootNavigator,
          }) async {
            final machine = await getMachine(
              historyLevel: historyLevel,
              useRootNavigator: useRootNavigator,
              tester: tester,
            );
            final mt = MachineTester(tester, machine);

            await mt.tap(E.jumpBack);

            await mt.tap(E.forward);
            await mt.tap(E.forward);
            await mt.tap(E.forward);
            await mt.tap(E.forward);
            await mt.tap(E.forward);
            await mt.tap(E.forward);

            await mt.backButton();

            await mt.fire(E.jump, 'root');
            await mt.fire(E.jumpBack, 'root');
          });
        },
        skip: false,
      );

      testWidgets(
        'Chain of paged and pageless.',
        (tester) async {
          await multiplier(({
            required HistoryLevel? historyLevel,
            required bool useRootNavigator,
          }) async {
            final machine = await getChainMachine(
              historyLevel: historyLevel,
              useRootNavigator: useRootNavigator,
              tester: tester,
            );
            final mt = MachineTester(tester, machine);

            await mt.fire(E.forward, 'root');
            await mt.fire(E.forward, 'child');
            await mt.fire(E.forward, 'child');
            await mt.fire(E.back, 'child');

            await mt.fire(E.back, 'root');
            await mt.fire(E.forward, 'root');
          });
        },
        skip: false,
      );
    },
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

Future<void> multiplier(
  Future<void> Function({
    required HistoryLevel? historyLevel,
    required bool useRootNavigator,
  })
      tc,
) async {
  await tc(historyLevel: null, useRootNavigator: false);
  await tc(historyLevel: null, useRootNavigator: true);

  await tc(historyLevel: HistoryLevel.shallow, useRootNavigator: false);
  await tc(historyLevel: HistoryLevel.shallow, useRootNavigator: true);

  await tc(historyLevel: HistoryLevel.deep, useRootNavigator: false);
  await tc(historyLevel: HistoryLevel.deep, useRootNavigator: true);
}

Future<StateMachineWithChangeNotifier<S, E, T>> getMachine({
  required HistoryLevel? historyLevel,
  required bool useRootNavigator,
  required WidgetTester tester,
}) async {
  print('----------------------------------------------------------------');
  print('historyLevel: $historyLevel, useRootNavigator: $useRootNavigator');
  final machine = createMachine(name: 'root', historyLevel: historyLevel);
  await machine.start();
  // Build our app and trigger a frame.
  await tester.pumpWidget(
    MyApp(machine: machine, useRootNavigator: useRootNavigator),
  );

  checkTitle(machine, S.a);
  return machine;
}

Future<StateMachineWithChangeNotifier<S, E, T>> getChainMachine({
  required HistoryLevel? historyLevel,
  required bool useRootNavigator,
  required WidgetTester tester,
}) async {
  print('----------------------------------------------------------------');
  print('historyLevel: $historyLevel, useRootNavigator: $useRootNavigator');
  final machine =
      createParentChainMachine(name: 'root', historyLevel: historyLevel);
  await machine.start();
  // Build our app and trigger a frame.
  await tester.pumpWidget(
    ChainApp(machine: machine, useRootNavigator: useRootNavigator),
  );

  checkTitle(machine, S.a);
  return machine;
}
