import 'dart:async';

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:test/test.dart';

const _testName = 'state_change_inside_state_change_test';
final _log = getLogger(_testName);

Future<void> main() async {
  // initLogging();
  // StateMachine.monitorCreators = [
  //   (machine) => ConsoleMonitor(machine),
  // ];

  group(
    'Group A',
    () {
      test('Test 1', () async {
        final m1 = createMachine1();
        unawaited(
          Future<void>.delayed(const Duration(seconds: 1)).then((value) async {
            _log.finest('# FIRE start.');
            await m1.fire(E.c);
            _log.finest('# FIRE stop.');
          }),
        );

        await m1.start();
        _log.finest('m1.data:${m1.data}');

        await m1.fire(E.b);
        _log.finest('m1.data:${m1.data}');
        _log.finest('main finished.');
      });
    },
    skip: true,
  );

  test('B1', () async {
    final m2 = createMachine2();

    await m2.start();
    await m2.fire(E.b, arg: {Sel.onExit});
    expect(m2.activeStateId, S.b);
  });

  test('B2', () async {
    final m2 = createMachine2();

    await m2.start();
    await m2.fire(E.b, arg: {Sel.guard});
    expect(m2.activeStateId, S.b);
  });

  test('B3', () async {
    final m2 = createMachine2();

    await m2.start();
    await m2.fire(E.b, arg: {Sel.action});
    expect(m2.activeStateId, S.b);
  });

  test('B4', () async {
    final m2 = createMachine2();

    await m2.start();
    await m2.fire(E.b, arg: {Sel.onEntry});
    // TODO: this should be S.b.
    // If queuing will be added to hisma it will be S.b.
    expect(m2.activeStateId, S.c);
  });
}

enum S { a, b, c, f }

enum E { a, b, c, f }

enum T { a, b, c, f }

Machine<S, E, T> createMachine1() => Machine<S, E, T>(
      data: 0,
      events: E.values,
      name: 'm1',
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.b: [T.b],
            E.f: [T.f],
            E.c: [T.c],
          },
          onEntry: addAction('S.a onEntry'),
          onExit: addAction('S.a onExit'),
        ),
        S.b: State(
          etm: {
            E.a: [T.a],
          },
          // onEntry: Action(
          //   description: 'fire',
          //   action: (machine, arg) async {
          //     _log.finest('> S.b onEntry started.');
          //     await machine.fire(E.a);
          //     _log.finest('>     S.b onEntry finished.');
          //   },
          // ),
          onExit: addAction('S.b onExit'),
        ),
        S.c: State(),
        S.f: FinalState(),
      },
      transitions: {
        T.a: Transition(to: S.a, onAction: addAction('T.a onAction')),
        T.b: Transition(
          to: S.b,
          onAction: addAction('T.b onAction'),
          guard: Guard(
            description: 'g1',
            condition: (machine, arg) async {
              _log.finest('> T.b Guard started.');
              await Future<void>.delayed(const Duration(seconds: 3));
              _log.finest('>     T.b Guard finished.');
              return true;
            },
          ),
        ),
        T.c: Transition(to: S.c),
        T.f: Transition(to: S.f),
      },
    );

Action addAction(String name) => Action(
      description: name,
      action: (machine, arg) {
        _log.finest('> $name started.');
        final tmp = (machine.data as int) + 1;

        // await Future<void>.delayed(const Duration(seconds: 1));
        // await machine.fire(E.b);

        machine.data = tmp;
        _log.finest('>     $name finished.');
      },
    );

Machine<S, E, T> createMachine2() => Machine<S, E, T>(
      data: 0,
      events: E.values,
      name: 'm1',
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.b: [T.b],
            E.c: [T.c],
          },
          onEntry: createGenAction(Sel.onEntry),
          onExit: createGenAction(Sel.onExit),
        ),
        S.b: State(
          etm: {
            E.c: [T.c],
          },
          onEntry: createGenAction(Sel.onEntry),
          onExit: createGenAction(Sel.onExit),
        ),
        S.c: State(),
        S.f: FinalState(),
      },
      transitions: {
        T.a: Transition(to: S.a),
        T.b: Transition(
          to: S.b,
          guard: Guard(
            description: 'S.b guard',
            condition: (machine, arg) async {
              if (((arg ?? <Sel>{}) as Set<Sel>).contains(Sel.guard)) {
                await machine.fire(E.c);
              }
              return true;
            },
          ),
          onAction: createGenAction(Sel.action),
        ),
        T.c: Transition(to: S.c),
        T.f: Transition(to: S.f),
      },
    );

Action createGenAction(Sel sel) => Action(
      description: 'go to S.c',
      action: (machine, arg) async {
        if (((arg ?? <Sel>{}) as Set<Sel>).contains(sel)) {
          _log.finest('Fire - $sel & $arg');
          await machine.fire(E.c);
        }
      },
    );

enum Sel { guard, action, onEntry, onExit }
