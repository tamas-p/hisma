// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { a, b, end }

enum E { changeException, changeOnError, finish }

enum T { toA, toBThrow, toBOnError, toEnd }

StateMachine<S, E, T> createSimpleMachine(String name) => StateMachine<S, E, T>(
      data: false,
      name: name,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.changeException: [T.toBThrow],
            E.changeOnError: [T.toBOnError],
          },
        ),
        S.b: State(
          etm: {
            E.changeException: [T.toA],
            E.changeOnError: [T.toA],
            E.finish: [T.toEnd],
          },
        ),
        S.end: FinalState(),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toBThrow: Transition(
          to: S.b,
          minInterval: const Duration(milliseconds: 100),
        ),
        T.toBOnError: Transition(
          to: S.b,
          minInterval: const Duration(milliseconds: 100),
          onError: (machine, message) async {
            machine.data = true;
          },
        ),
        T.toEnd: Transition(to: S.end),
      },
    );
void main() {
  group('Transition interval test', () {
    test('Interval test positive - throw', () async {
      final m1 = createSimpleMachine('m1');
      expect(m1.activeStateId, equals(null));
      await m1.start();
      expect(m1.activeStateId, equals(S.a));

      await m1.fire(E.changeException);
      expect(m1.activeStateId, equals(S.b));
      await m1.fire(E.changeException);
      expect(m1.activeStateId, equals(S.a));

      await Future<void>.delayed(const Duration(milliseconds: 101));
      await m1.fire(E.changeException);
      expect(m1.activeStateId, equals(S.b));
      expect(m1.data as bool, false);
    });

    test('Interval test positive - onError', () async {
      final m1 = createSimpleMachine('m1');
      expect(m1.activeStateId, equals(null));
      await m1.start();
      expect(m1.activeStateId, equals(S.a));

      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, equals(S.b));
      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, equals(S.a));

      await Future<void>.delayed(const Duration(milliseconds: 101));
      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, equals(S.b));
      expect(m1.data as bool, false);
    });

    test('Interval test negative - throw', () async {
      final m1 = createSimpleMachine('m1');
      expect(m1.activeStateId, equals(null));
      await m1.start();
      expect(m1.activeStateId, equals(S.a));

      await m1.fire(E.changeException);
      expect(m1.activeStateId, equals(S.b));
      await m1.fire(E.changeException);
      expect(m1.activeStateId, equals(S.a));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        m1.fire(E.changeException),
        throwsA(const TypeMatcher<HismaIntervalException>()),
      );
      expect(m1.data as bool, false);
    });

    test('Interval test negative - onError', () async {
      final m1 = createSimpleMachine('m1');
      expect(m1.activeStateId, equals(null));
      await m1.start();
      expect(m1.activeStateId, equals(S.a));

      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, equals(S.b));
      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, equals(S.a));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await m1.fire(E.changeOnError);
      expect(m1.data as bool, true);
    });
  });
}
