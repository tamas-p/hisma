// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { a, b, end }

enum E { change, finish }

enum T { toA, toB, toEnd }

StateMachine<S, E, T> createSimpleMachine(String name) => StateMachine<S, E, T>(
      name: name,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.change: [T.toB],
          },
        ),
        S.b: State(
          etm: {
            E.change: [T.toA],
            E.finish: [T.toEnd],
          },
        ),
        S.end: FinalState(),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(
          to: S.b,
          minInterval: const Duration(milliseconds: 100),
        ),
        T.toEnd: Transition(to: S.end),
      },
    );
void main() {
  group('Transition interval test', () {
    test('Interval test positive', () async {
      final m1 = createSimpleMachine('m1');
      expect(m1.activeStateId, equals(null));
      await m1.start();
      expect(m1.activeStateId, equals(S.a));

      await m1.fire(E.change);
      expect(m1.activeStateId, equals(S.b));
      await m1.fire(E.change);
      expect(m1.activeStateId, equals(S.a));

      await Future<void>.delayed(const Duration(milliseconds: 101));
      await m1.fire(E.change);
      expect(m1.activeStateId, equals(S.b));
    });

    test('Interval test negative', () async {
      final m1 = createSimpleMachine('m1');
      expect(m1.activeStateId, equals(null));
      await m1.start();
      expect(m1.activeStateId, equals(S.a));

      await m1.fire(E.change);
      expect(m1.activeStateId, equals(S.b));
      await m1.fire(E.change);
      expect(m1.activeStateId, equals(S.a));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        m1.fire(E.change),
        throwsA(const TypeMatcher<HismaIntervalException>()),
      );
    });
  });
}
