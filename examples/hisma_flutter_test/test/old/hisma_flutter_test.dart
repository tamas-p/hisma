import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/old/chain_machine.dart';
import 'package:hisma_flutter_test/old/machine.dart';
import 'package:hisma_flutter_test/old/main.dart';
import 'package:hisma_flutter_test/old/states_events_transitions.dart';
import 'package:hisma_flutter_test/ui.dart';
import 'package:logging/logging.dart';

import '../aux/aux.dart';

const _loggerName = 'FlutterTest';
final Logger _log = Logger(_loggerName);

void main() {
  // auxInitLogging();
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  //   (m) => ConsoleMonitor(m),
  // ];
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

        await testIt(machine: machine, tester: tester, act: Act.tap);
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

        await testIt(machine: machine, tester: tester, act: Act.fire);
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

  group('Pageless routes.', skip: false, () {
    testWidgets(
      '''
Testing that pageless routes are managed well in case of a root machine.
''',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
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
            find.textContaining(E.jumpBack.toString()).first,
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

    testWidgets(
      '''
Testing that pageless routes are managed well in case of a child machine.
''',
      (tester) async {
        const machineName = 'root';
        await tester.binding.setSurfaceSize(const Size(1024, 1024));
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
            find.textContaining(E.jumpBack.toString()).first,
            warnIfMissed: false,
          );
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

        await mt.tapL(E.jumpBack);
        await mt.tapL(E.forward);
        await mt.tapL(E.forward);
        await mt.tapL(E.forward);
        await mt.tapL(E.forward);

        await mt.fire(E.forward, 'root');
        await mt.tapL(E.jump);

        await mt.tapL(E.jumpBack);

        await mt.tapL(E.forward);
        await mt.tapL(E.self);
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

        await mt.tapL(E.jumpBack);
        await mt.tapL(E.forward);
        await mt.tapL(E.forward);
        await mt.tapL(E.forward);

        await mt.fire(E.jump, 'root');
        await mt.tapL(E.jumpBack);

        await mt.tapL(E.forward);
        await mt.tapL(E.self);
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

        await mt.tapL(E.jumpBack);
        await mt.tapF(E.jumpBack);

        await mt.fire(E.back, 'root/S.l');

        await mt.fire(E.jumpBack, 'root/S.l');
        await mt.tapL(E.jumpBack);

        await mt.fire(E.forward, 'root');
        await mt.tapL(E.jump);

        await mt.tapL(E.jumpBack);

        await mt.tapL(E.forward);
      });
    },
    skip: false,
  );

  testWidgets(
    'Machine has not been started test.',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
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
        await mt.tapL(E.jumpBack);
        // await mt.fire(E.self, 'root');
        await mt.fire(E.forward, 'root/S.l');
        // await mt.tap(E.self);
        // await mt.tap(E.self);
        await mt.fire(E.jumpBack, 'root/S.l');
        await mt.tapF(E.jumpBack);
        // await mt.tap(E.self);
        await mt.tapF(E.forward);
        await mt.tapF(E.back);
        await mt.tapF(E.forward);
        // await mt.fire(E.self, 'root');
        await mt.tapF(E.jumpBack);
        await mt.fire(E.jumpBack, 'root/S.l'); // THIS
        await mt.tapL(E.jumpBack);
        // await mt.fire(E.self, 'root/S.l');

        await mt.fire(E.forward, 'root');
        await mt.tapL(E.jump);

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

        await mt.tapL(E.jumpBack);

        // await mt.fire(E.jumpBack, 'root');
        await mt.tapL(E.forward);

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
    skip: true,
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

        await mt.tapF(E.back);

        await mt.tapF(E.jumpBack);
        await mt.tapF(E.jumpBack);
        await mt.fire(E.forward, 'root/S.k');
        await mt.fire(E.back, 'root');
      });
    },
    skip: false,
  );

  testWidgets(
    'Expected: exactly one matching node in the widget tree',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1024));
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
        await mt.tapF(E.self);
        await mt.tapF(E.forward);
        await mt.fire(E.self, 'root');
        await mt.tapF(E.forward);
        await mt.tapF(E.jumpBack);
        await mt.fire(E.forward, 'root');
        await mt.fire(E.jumpBack, 'root');
        await mt.tapF(E.back);
        // Old test machine does not have a circle when tapped on back button.
        // await mt.backButton();
      });
    },
    skip: false,
  );

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

        await mt.tapF(E.back);
        await mt.tapF(E.back);
        await mt.tapL(E.back);
        await mt.tapF(E.back);
        await mt.tapF(E.back);

        // Here when we are back to S.l/S.a the S.l/S.m dialog was still shown.
        await mt.fire(E.self, 'root');

        await mt.fire(E.forward, 'root/S.l'); // here
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
        await mt.tapF(E.jumpBack);
        await mt.tapF(E.back);
        await mt.fire(E.forward, 'root');
        await mt.tapF(E.back);
        await mt.tapF(E.forward);
        await mt.tapF(E.jumpBack);
        await mt.tapF(E.jumpBack);
        await mt.fire(E.back, 'root');
        await mt.fire(E.forward, 'root/S.k');
        await mt.tapF(E.back);
        await mt.fire(E.jumpBack, 'root/S.k');
        // await mt.fire(E.self, 'root/S.k/S.l');
        await mt.tapF(E.jumpBack);
        await mt.fire(E.forward, 'root/S.k');
        await mt.fire(E.forward, 'root');

        await mt.tapF(E.forward);
        await mt.fire(E.jumpBack, 'root/S.l');
      });
    },
    skip: true,
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

        await mt.tapF(E.jumpBack);
        await mt.fire(E.back, 'root');
        await mt.tapF(E.jumpBack);
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
        await mt.tapF(E.jumpBack);
        await mt.tapF(E.back);
        await mt.tapF(E.back);
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

            await mt.tapL(E.jumpBack);

            await mt.tapL(E.forward);
            await mt.tapL(E.forward);
            await mt.tapL(E.forward);
            await mt.tapL(E.forward);
            await mt.tapL(E.forward);
            await mt.tapL(E.forward);

            await mt.backButton();

            await mt.fire(E.jump, 'root');
            await mt.fire(E.jumpBack, 'root');
          });
        },
        skip: true,
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

Future<void> checkAll(
  StateMachineWithChangeNotifier<S, E, T> machine,
  WidgetTester tester,
  S previous,
  S current,
  S next, {
  Act act = Act.tap,
}) async {
  await action(machine, tester, E.back, act: act);
  checkTitle(machine, previous);

  await action(machine, tester, E.forward, act: act);
  checkTitle(machine, current);

  await action(machine, tester, E.self, act: act);
  checkTitle(machine, current);

  await action(machine, tester, E.forward, act: act);
  checkTitle(machine, next);
}

Future<void> testIt({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required WidgetTester tester,
  required Act act,
}) async {
  await checkAll(machine, tester, S.n, S.a, S.b, act: act);
  await checkAll(machine, tester, S.a, S.b, S.c, act: act);
  await checkAll(machine, tester, S.b, S.c, S.d, act: act);
  await checkAll(machine, tester, S.c, S.d, S.e, act: act);
  await checkAll(machine, tester, S.d, S.e, S.f, act: act);
  await checkAll(machine, tester, S.e, S.f, S.g, act: act);
  await checkAll(machine, tester, S.f, S.g, S.h, act: act);
  await checkAll(machine, tester, S.g, S.h, S.i, act: act);
  await checkAll(machine, tester, S.h, S.i, S.j, act: act);

  await checkAll(machine, tester, S.i, S.j, S.k, act: act);
  await checkAll(machine, tester, S.j, S.k, S.l, act: act);
  await checkAll(machine, tester, S.k, S.l, S.m, act: act);
  await checkAll(machine, tester, S.l, S.m, S.n, act: act);
  await checkAll(machine, tester, S.m, S.n, S.a, act: act);
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

  Future<void> tapF(E eventId) async {
    _log.info('${machine.getActiveStateRecursive()} <tap> $eventId');
    await tester.tap(find.textContaining(eventId.toString()).first);
    await _check();
  }

  Future<void> tapL(E eventId) async {
    _log.info('${machine.getActiveStateRecursive()} <tap> $eventId');
    await tester.tap(find.textContaining(eventId.toString()).last);
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

  // History state shall not be used.
  // await tc(historyLevel: HistoryLevel.shallow, useRootNavigator: false);
  // await tc(historyLevel: HistoryLevel.shallow, useRootNavigator: true);

  // await tc(historyLevel: HistoryLevel.deep, useRootNavigator: false);
  // await tc(historyLevel: HistoryLevel.deep, useRootNavigator: true);
}

Future<StateMachineWithChangeNotifier<S, E, T>> getMachine({
  required HistoryLevel? historyLevel,
  required bool useRootNavigator,
  required WidgetTester tester,
}) async {
  // print('----------------------------------------------------------------');
  // print('historyLevel: $historyLevel, useRootNavigator: $useRootNavigator');
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
  // print('----------------------------------------------------------------');
  // print('historyLevel: $historyLevel, useRootNavigator: $useRootNavigator');
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
