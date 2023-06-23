import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/machine.dart';
import 'package:hisma_flutter_test/main.dart';
import 'package:logging/logging.dart';

import '../../../examples/hisma_flutter_test/test/aux/aux.dart';

const _loggerName = 'HismaMonkeyTest';
final Logger _log = Logger(_loggerName);

void main() {
  auxInitLogging();

  // The purpose of this test to randomly generate events either by tapping on
  // UI or directly firing events on a randomly selected active machine of the
  // hierarchical state machine. This allows us finding problems mainly in
  // hisma_flutter that we missed discovering with regular auto-tests.
  group(
    'Monkey test.',
    () {
      testWidgets(
        'No History monkey, useRootNavigator: false',
        (tester) async {
          StateMachine.monitorCreators = [
            // (m) => VisualMonitor(m, host: '192.168.122.1'),
          ];

          await monkey(
            tester: tester,
            machine: createMachine(name: 'root'),
            useRootNavigator: false,
          );
        },
        skip: true,
      );
      testWidgets(
        'No History monkey, useRootNavigator: true',
        (tester) async {
          StateMachine.monitorCreators = [
            // (m) => VisualMonitor(m, host: '192.168.122.1'),
          ];

          await monkey(
            tester: tester,
            machine: createMachine(name: 'root'),
            useRootNavigator: true,
          );
        },
        skip: true,
      );
      testWidgets(
        'Shallow history monkey, useRootNavigator: false',
        (tester) async {
          StateMachine.monitorCreators = [
            // (m) => VisualMonitor(m, host: '192.168.122.1'),
          ];

          await monkey(
            tester: tester,
            machine:
                createMachine(name: 'root', historyLevel: HistoryLevel.shallow),
            useRootNavigator: false,
          );
        },
        skip: true,
      );
      testWidgets(
        'Shallow history monkey, useRootNavigator: true',
        (tester) async {
          StateMachine.monitorCreators = [
            // (m) => VisualMonitor(m, host: '192.168.122.1'),
          ];

          await monkey(
            tester: tester,
            machine:
                createMachine(name: 'root', historyLevel: HistoryLevel.shallow),
            useRootNavigator: true,
          );
        },
        skip: false,
      );
      testWidgets(
        'Deep history monkey, useRootNavigator: false',
        (tester) async {
          StateMachine.monitorCreators = [
            // (m) => VisualMonitor(m, host: '192.168.122.1'),
          ];

          await monkey(
            tester: tester,
            machine:
                createMachine(name: 'root', historyLevel: HistoryLevel.deep),
            useRootNavigator: false,
          );
        },
        skip: true,
      );
      testWidgets(
        'Deep history monkey, useRootNavigator: true',
        (tester) async {
          StateMachine.monitorCreators = [
            // (m) => VisualMonitor(m, host: '192.168.122.1'),
          ];

          await monkey(
            tester: tester,
            machine:
                createMachine(name: 'root', historyLevel: HistoryLevel.deep),
            useRootNavigator: true,
          );
        },
        skip: true,
      );
    },
  );
}

Future<void> monkey({
  required WidgetTester tester,
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool useRootNavigator,
}) async {
  await machine.start();
  // Build our app and trigger a frame.
  await tester.pumpWidget(
    MyApp(machine: machine, useRootNavigator: useRootNavigator),
  );
  final stateId = machine.activeStateId;
  if (stateId == null) throw AssertionError();
  final state = machine.stateAt(stateId);
  // We have the same events everywhere. No need to update.
  final events = state?.etm.keys;

  for (var i = 0; i < 50; i++) {
    // if (i != 0 && i % 1000 == 0) {
    //   print('Have some rest...');
    //   await tester.runAsync(() async {
    //     await Future<void>.delayed(const Duration(milliseconds: 300));
    //   });
    //   print('Continue.');
    // }

    _log.info(' >>> $i <<<');
    final rnd = Random();
    final randomEvent = events?.toList()[rnd.nextInt(events.length)];
    if (randomEvent == E.jump) {
      if (rnd.nextInt(100) < 70) continue;
    }
    if (randomEvent == null) throw AssertionError();

    _log.info('-------------------------------------------------------');
    _log.info('BEFORE:');
    _log.info(() => machine.getActiveStateRecursive());

    if (rnd.nextBool() == true) {
      await tester.pumpAndSettle();

      if (isThereBackButton() && rnd.nextInt(100) < 25) {
        _log.info('Tap PageBack');
        await pageBack(tester);
      } else {
        _log.info(
          () =>
              'await mt.tap(find.text($randomEvent).last, warnIfMissed: false);',
        );
        _log.info('Tap $randomEvent');
        await tester.tap(find.text('$randomEvent').last, warnIfMissed: false);
      }
      await tester.pumpAndSettle();
    } else {
      await tester.pumpAndSettle();
      _log.info(() => getActiveMachines(machine).map((e) => e.name));

      final activeMachines = getActiveMachines(machine);
      final rndMachine = activeMachines[rnd.nextInt(activeMachines.length)];

      // await machine.fire(randomEvent);
      _log.info(() => 'rndMachine.fire($randomEvent) - ${rndMachine.name}');
      await rndMachine.fire(randomEvent);
      await tester.pumpAndSettle();
    }

    _log.info('AFTER:');
    _log.info(() => machine.getActiveStateRecursive());

    // await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    checkTitle(machine);
  }
}
