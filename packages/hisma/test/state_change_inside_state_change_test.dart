// ignore_for_file: avoid_print

import 'dart:async';

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';

enum S { a, b, c, f }

enum E { a, b, c, f }

enum T { a, b, c, f }

final m1 = StateMachine<S, E, T>(
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
      //     print('> S.b onEntry started.');
      //     await machine.fire(E.a);
      //     print('>     S.b onEntry finished.');
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
          print('> T.b Guard started.');
          await Future<void>.delayed(const Duration(seconds: 3));
          print('>     T.b Guard finished.');
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
      action: (machine, arg) async {
        print('> $name started.');
        final tmp = (machine.data as int) + 1;

        // await Future<void>.delayed(const Duration(seconds: 1));
        // await machine.fire(E.b);

        machine.data = tmp;
        print('>     $name finished.');
      },
    );

Future<void> main() async {
  StateMachine.monitorCreators = [
    (machine) => ConsoleMonitor(machine),
  ];

  unawaited(
    Future<void>.delayed(const Duration(seconds: 1)).then((value) async {
      print('# FIRE start.');
      await m1.fire(E.c);
      print('# FIRE stop.');
    }),
  );

  await m1.start();
  print('m1.data:${m1.data}');

  await m1.fire(E.b);
  print('m1.data:${m1.data}');

  print('main finished.');
}
