import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

void main() {
  group('Data initialization tests', () {
    test('data initialization 1', () async {
      final m1 = createMachine();
      expect(m1.data, null);
      await m1.start();
      expect(m1.data, null);
    });

    test('data initialization 2', () async {
      final m1 = createMachine(0);
      expect(m1.data, 0);
      await m1.start();
      expect(m1.data, 0);
    });
    test(
      'data initialization 3',
      () async {
        final m1 = createMachine();
        expect(m1.data, null);
        await m1.start(arg: 0);
        expect(m1.data, 0);
      },
      skip: true,
    );
    test(
      'data initialization 4',
      () async {
        final m1 = createMachine(0);
        expect(m1.data, 0);
        await m1.start(arg: 1);
        expect(m1.data, 1);
      },
      skip: true,
    );
  });

  group('Action tests', () {
    test(
      'Action test 1',
      () async {
        var value = 50;
        final m1 = createMachine(value);
        expect(m1.data, value);
        await m1.start();
        expect(m1.activeStateId, S.a);

        value = value * 2; // S.a onEntry
        expect(m1.data, value);

        await m1.fire(E.triple); // T.triple
        value = value * 3;
        await m1.fire(E.trisect); // T.trisect
        value = value ~/ 3;

        expect(m1.data, value);

        for (var i = 0; i < 100; i++) {
          await m1.fire(E.inc);
          value = value + 2; // T.toB
          value = value ~/ 2; // S.a onExit

          await m1.fire(E.triple); // T.triple
          value = value * 3;
          await m1.fire(E.trisect); // T.trisect
          value = value ~/ 3;

          expect(m1.activeStateId, S.b);
          expect(m1.data, value);

          await m1.fire(E.dec);
          value = value - 2; // T.toA
          value = value * 2; // S.a onEntry

          await m1.fire(E.triple); // T.triple
          value = value * 3;
          await m1.fire(E.trisect); // T.trisect
          value = value ~/ 3;

          expect(m1.activeStateId, S.a);
          expect(m1.data, value);
        }
      },
    );
  });
}

enum S { a, b }

enum E { inc, dec, triple, trisect }

enum T { toA, toB, triple, trisect }

Machine<S, E, T> createMachine([dynamic data]) => Machine<S, E, T>(
      name: 'm1',
      data: data,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.inc: [T.toB],
            E.triple: [T.triple],
            E.trisect: [T.trisect],
          },
          onEntry: Action(
            description: 'double',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data * 2;
            },
          ),
          onExit: Action(
            description: 'half',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data ~/ 2;
            },
          ),
        ),
        S.b: State(
          etm: {
            E.dec: [T.toA],
            E.triple: [T.triple],
            E.trisect: [T.trisect],
          },
        ),
      },
      transitions: {
        T.toA: Transition(
          to: S.a,
          onAction: Action(
            description: 'decrease',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data - 2;
            },
          ),
        ),
        T.toB: Transition(
          to: S.b,
          onAction: Action(
            description: 'increase',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data + 2;
            },
          ),
        ),
        T.triple: InternalTransition(
          onAction: Action(
            description: 'Triple it.',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data * 3;
            },
          ),
        ),
        T.trisect: InternalTransition(
          onAction: Action(
            description: 'Trisect it.',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data ~/ 3;
            },
          ),
        ),
      },
    );
