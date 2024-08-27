// @Timeout(Duration(seconds: 645))

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:test/test.dart';

import 'util.dart';

const smTestName = 'sm_test';
final _log = getLogger(smTestName);

void main() {
  late StateMachine<L1S, L1E, L1T> sm;
  setUp(() {
    sm = StateMachine<L1S, L1E, L1T>(
      name: 'sm1',
      initialStateId: L1S.s1,
      states: {
        L1S.s1: State(
          etm: {
            L1E.e1: [L1T.t1],
          },
        ),
        L1S.s2: State(
          etm: {
            L1E.e2: [L1T.t2],
          },
        ),
      },
      transitions: {
        L1T.t1: Transition(to: L1S.s2),
        L1T.t2: Transition(to: L1S.s1),
      },
    );
  });

  group('Basic state machine tests.', () {
    test('Starting state machine normally.', () {
      expect(
        sm.start(),
        completion(equals(null)),
      );
    });
    test('Already started state machine.', () {
      // No await on purpose to see if basic flagging state machine
      // works (happens before 1st await in the start method).
      sm.start();
      expect(
        sm.start(),
        throwsA(isA<AssertionError>()),
      );
    });
    test('Fire when state machine is not started.', () {
      expect(
        sm.fire(L1E.e1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Fire appropriate event.', () async {
      await sm.start();
      expect(
        sm.fire(L1E.e1),
        completion(equals(null)),
      );
    });

    test('Fire inappropriate event.', () async {
      await sm.start();
      expect(
        sm.fire(L1E.e2),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('State changes tests.', () {
    test('Check active state after start.', () async {
      await sm.start();
      expect(
        sm.getActiveStateRecursive(),
        equals([L1S.s1]),
      );
    });
    test('Check active state after event.', () async {
      await sm.start();
      expect(
        sm.getActiveStateRecursive(),
        equals([L1S.s1]),
      );
      await expectLater(
        sm.fire(L1E.e1),
        completion(equals(null)),
      );
      expect(
        sm.getActiveStateRecursive(),
        equals([L1S.s2]),
      );
    });

    test('Check active state after multiple events.', () async {
      _log.info('Started.');
      _log.info(() => pretty(sm.getActiveStateRecursive()));
      await sm.start();
      _log.info(() => pretty(sm.getActiveStateRecursive()));
      expect(
        sm.getActiveStateRecursive(),
        equals([L1S.s1]),
      );

      await fireAndCheck(sm, L1E.e1, [L1S.s2]);
      await fireAndCheck(sm, L1E.e2, [L1S.s1]);
      await fireAndCheck(sm, L1E.e1, [L1S.s2]);
      await fireAndCheck(sm, L1E.e2, [L1S.s1]);
      await fireAndCheck(sm, L1E.e1, [L1S.s2]);
      await fireAndCheck(sm, L1E.e2, [L1S.s1]);
      await fireAndCheck(sm, L1E.e1, [L1S.s2]);
      await fireAndCheck(sm, L1E.e2, [L1S.s1]);
    });

    test(
      'Simple state check 2.',
      () async {
        _log.info('<1>');
        await expectLater(
          // Future<void>.delayed(const Duration(seconds: 1)),
          Future<void>.delayed(const Duration(seconds: 5), () => 12),
          // Future<int>.value(12),
          // completion(equals(null)),
          completion(equals(12)),
          // equals(12),
          // completion(returnsNormally),
        );
        _log.info('<2>');
        expect(
          // Future<void>.delayed(const Duration(seconds: 1)),
          Future<void>.delayed(const Duration(seconds: 5), () => 12),
          // Future<int>.value(12),
          // completion(equals(null)),
          completion(equals(12)),
          // equals(12),
          // completion(returnsNormally),
        );
        _log.info('<3>');
      },
      skip: true,
    );
  });
}
