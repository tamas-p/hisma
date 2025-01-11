import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

void main() {
  group('Data initialization tests', () {
    test('data initialization 1', () async {
      final m1 = createMachine();
      expect(m1.data, equals(null));
      await m1.start();
      expect(m1.data, equals(null));
    });

    test('data initialization 2', () async {
      final m1 = createMachine(0);
      expect(m1.data, equals(0));
      await m1.start();
      expect(m1.data, equals(0));
    });
    test(
      'data initialization 3',
      () async {
        final m1 = createMachine();
        expect(m1.data, equals(null));
        await m1.start(arg: 0);
        expect(m1.data, equals(null));
      },
    );
    test(
      'data initialization 4',
      () async {
        final m1 = createMachine(0);
        expect(m1.data, equals(0));
        await m1.start(arg: 1);
        expect(m1.data, equals(0));
        m1.data = 10;
        expect(m1.data, equals(10));
      },
    );
  });

  group('Action tests', () {
    test(
      'Action test 1',
      () async {
        final m1 = createMachine(0);
        expect(m1.data, equals(0));
        await m1.start();
        expect(m1.data, equals(0));

        for (var i = 0; i < 100; i++) {
          await m1.fire(E.inc);
          expect(m1.data, equals(1));

          await m1.fire(E.dec);
          expect(m1.data, equals(0));
        }
      },
    );
  });

  test(
    'Action test 2 - with args',
    () async {
      final m1 = createMachine(0);
      expect(m1.data, equals(0));
      await m1.start();
      expect(m1.data, equals(0));

      for (var i = 0; i < 100; i++) {
        await m1.fire(E.inc, arg: 10);
        expect(m1.data, equals(10));

        await m1.fire(E.dec, arg: 10);
        expect(m1.data, equals(0));
      }
    },
  );
}

enum S { a, b }

enum E { inc, dec }

enum T { toA, toB }

Machine<S, E, T> createMachine([dynamic data]) => Machine<S, E, T>(
      name: 'm1',
      data: data,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.inc: [T.toB],
          },
        ),
        S.b: State(
          etm: {
            E.dec: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: Transition(
          to: S.a,
          onAction: Action(
            description: 'decrease',
            action: (machine, arg) {
              machine.data =
                  (machine.data as int) - (arg != null && arg is int ? arg : 1);
            },
          ),
        ),
        T.toB: Transition(
          to: S.b,
          onAction: Action(
            description: 'increase',
            action: (machine, arg) {
              machine.data =
                  (machine.data as int) + (arg != null && arg is int ? arg : 1);
            },
          ),
        ),
      },
    );
