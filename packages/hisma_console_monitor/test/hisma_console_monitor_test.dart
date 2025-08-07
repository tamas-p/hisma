// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:test/test.dart';

void main() {
  Machine.monitorCreators = [
    (m) => ConsoleMonitor(m),
  ];
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      print('getMachine() ---------------------------------------------------');
      final m = getMachine();
      print('m.start() ------------------------------------------------------');
      await m.start();
      print('m.fire(E.forward) ----------------------------------------------');
      await m.fire(E.forward);
      print("m.find<S, E, T>('l1a').fire(E.forward) -------------------------");
      await m.find<S, E, T>('l1a').fire(E.forward);
      print("m.find<S, E, T>('l2a').fire(E.forward) -------------------------");
      await m.find<S, E, T>('l2a').fire(E.forward);
      print("m.find<S, E, T>('l3a').fire(E.forward) -------------------------");
      await m.find<S, E, T>('l3a').fire(E.forward);
    });
  });
}

enum S { a, b }

enum E { forward }

enum T { toA, toB }

Machine<S, E, T> getMachine({
  int level = 0,
  String n = '',
}) =>
    Machine(
      name: 'l$level$n',
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: State(
          etm: {
            E.forward: [T.toA],
          },
          regions: [
            if (level < 3)
              Region<S, E, T, S>(machine: getMachine(level: level + 1, n: 'a')),
            if (level < 3)
              Region<S, E, T, S>(machine: getMachine(level: level + 1, n: 'b'))
          ],
        ),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
      },
    );
