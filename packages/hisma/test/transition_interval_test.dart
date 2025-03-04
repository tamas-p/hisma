import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

void main() {
  group('Transition interval test', () {
    test(
      'Interval test positive',
      () async {
        var value = 100;
        final m1 = createSimpleMachine('m1', value);
        expect(m1.activeStateId, null);
        expect(m1.data as int, value);

        await m1.start();
        expect(m1.activeStateId, S.a);
        expect(m1.data as int, value);

        await m1.fire(E.changeException);
        value = value * 2;
        expect(m1.activeStateId, S.b);
        expect(m1.data as int, value);

        await m1.fire(E.changeException);
        expect(m1.activeStateId, S.a);
        expect(m1.data as int, value);

        await Future<void>.delayed(const Duration(milliseconds: 101));
        await m1.fire(E.changeException);
        value = value * 2;
        expect(m1.activeStateId, S.b);
        expect(m1.data as int, value);
      },
    );

    test('Interval test positive - onError', () async {
      var value = 100;
      final m1 = createSimpleMachine('m1', value);
      expect(m1.activeStateId, null);
      expect(m1.data as int, value);

      await m1.start();
      expect(m1.activeStateId, S.a);
      expect(m1.data as int, value);

      await m1.fire(E.changeOnError);
      value = value * 2;
      expect(m1.activeStateId, S.b);
      expect(m1.data as int, value);

      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, S.a);
      expect(m1.data as int, value);

      await Future<void>.delayed(const Duration(milliseconds: 101));
      await m1.fire(E.changeOnError);
      value = value * 2;
      expect(m1.activeStateId, S.b);
      expect(m1.data as int, value);
    });

    test('Interval test negative - onError', () async {
      var value = 100;
      final m1 = createSimpleMachine('m1', value);
      expect(m1.activeStateId, null);
      expect(m1.data as int, value);

      await m1.start();
      expect(m1.activeStateId, S.a);
      expect(m1.data as int, value);

      await m1.fire(E.changeOnError);
      value *= 2;
      expect(m1.activeStateId, S.b);
      expect(m1.data as int, value);

      await m1.fire(E.changeOnError);
      expect(m1.activeStateId, S.a);
      expect(m1.data as int, value);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await m1.fire(E.changeOnError);
      value ~/= 2;
      expect(m1.activeStateId, S.a);
      expect(m1.data as int, value);
    });
  });
}

enum S { a, b, end }

enum E { changeException, changeOnError, finish }

enum T { toA, toBThrow, toBOnError, toEnd }

Machine<S, E, T> createSimpleMachine(String name, int value) =>
    Machine<S, E, T>(
      data: value,
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
          onAction: Action(
            description: 'double',
            action: (machine, arg) {
              machine.data = (machine.data as int) * 2;
            },
          ),
        ),
        T.toBOnError: Transition(
          to: S.b,
          minInterval: const Duration(milliseconds: 100),
          onAction: Action(
            description: 'double',
            action: (machine, arg) {
              machine.data = (machine.data as int) * 2;
            },
          ),
          onSkip: OnSkipAction(
            description: 'divide',
            action: (machine, onErrorData) {
              expect(onErrorData.source, SkipSource.maxInterval);
              machine.data = (machine.data as int) ~/ 2;
            },
          ),
        ),
        T.toEnd: Transition(to: S.end),
      },
    );
