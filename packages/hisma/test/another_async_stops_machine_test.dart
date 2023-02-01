// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { a, b, f }

enum E { change, finish }

enum T { toA, toB, toF }

final m1 = StateMachine(
  name: 'm1',
  initialStateId: S.a,
  states: {
    S.a: State(
      etm: {
        E.change: [T.toB],
        E.finish: [T.toF],
      },
    ),
    S.b: State(
      etm: {
        E.change: [T.toA],
      },
    ),
    S.f: FinalState(),
  },
  transitions: {
    T.toA: Transition(to: S.a),
    T.toB: Transition(
      to: S.b,
      onAction: Action(
        description: 'slow',
        action: (machine, arg) async {
          print('Started...');
          await Future<void>.delayed(const Duration(seconds: 1));
          print(machine.activeStateId);
        },
      ),
    ),
    T.toF: Transition(to: S.f),
  },
);

void main() {
  group('Asynchronous state change tests.', () {
    test('Async Test 1', () async {
      await m1.start();
      m1.fire(E.change);
      await m1.fire(E.finish);
      await Future<void>.delayed(const Duration(seconds: 3));
    });
  });
}
