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
        expect(m1.data, null);
      },
    );
    test(
      'data initialization 4',
      () async {
        final m1 = createMachine(0);
        expect(m1.data, 0);
        await m1.start(arg: 1);
        expect(m1.data, 0);
      },
    );
  });

  group('Action tests', () {
    test(
      'Action test 1',
      () async {
        var value = 50;
        final m1 = createMachine(value);

        // m1.addMonitors([
        //   (m) => VisualMonitor(m),
        // ]);

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
          value = value ~/ 2; // S.a onExit
          value = value + 2; // T.toB

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
          expect(m1.data, value);
          await m1.fire(E.trisect); // T.trisect
          value = value ~/ 3;
          expect(m1.data, value);

          expect(m1.activeStateId, S.a);
          expect(m1.data, value);
        }
      },
    );

    test(
      'Action test - onAction for FinalState',
      () async {
        var value = 50;
        final m1 = createMachine(value);

        // m1.addMonitors([
        //   (m) => VisualMonitor(m),
        // ]);

        expect(m1.data, value);
        await m1.start();
        value = value * 2; // S.a onEntry
        expect(m1.data, value);
        expect(m1.activeStateId, S.a);

        await m1.fire(E.finish);
        value = value + 10; // T.toFS guard
        value = value ~/ 2; // S.a onExit
        value = value ~/ 5; // T.toFS
        expect(m1.data, value);
      },
    );

    test(
      'Action test - onAction for ExitPoint',
      () async {
        var value = 50;
        final m1 = createMachine(value);

        // m1.addMonitors([
        //   (m) => VisualMonitor(m),
        // ]);

        expect(m1.data, value);
        await m1.start();
        value = value * 2; // S.a onEntry
        expect(m1.data, value);
        expect(m1.activeStateId, S.a);

        await m1.fire(E.exit);
        value = value + 10; // T.toFS guard
        value = value ~/ 2; // S.a onExit
        value = value * 5; // T.toEP
        expect(m1.data, value);
      },
    );
  });
}

enum S { a, b, fs, ep }

enum E { inc, dec, triple, trisect, finish, exit }

enum T { toA, toB, triple, trisect, toFS, toEP }

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
            E.finish: [T.toFS],
            E.exit: [T.toEP],
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
        S.fs: FinalState(),
        S.ep: ExitPoint(),
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
        T.toFS: Transition(
          to: S.fs,
          guard: Guard(
            description: 'Add 10',
            condition: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data + 10;
              return true;
            },
          ),
          onAction: Action(
            description: 'Divide by 5',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data ~/ 5;
            },
          ),
        ),
        T.toEP: Transition(
          to: S.ep,
          guard: Guard(
            description: 'Add 10',
            condition: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data + 10;
              return true;
            },
          ),
          onAction: Action(
            description: 'Multiply by 5',
            action: (machine, arg) {
              final data = machine.data;
              if (data is int) machine.data = data * 5;
            },
          ),
        ),
      },
    );
