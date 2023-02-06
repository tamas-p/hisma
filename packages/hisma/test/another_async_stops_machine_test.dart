// ignore_for_file: avoid_print

import 'dart:async';

import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { a, b, f }

enum E { change, finish }

enum T { toA, toB, toF }

final m1 = StateMachine<S, E, T>(
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
    T.toA: Transition(
      to: S.a,
      onAction: createAction(),
    ),
    T.toB: Transition(
      to: S.b,
      onAction: createAction(),
    ),
    T.toF: Transition(
      to: S.f,
      onAction: createAction(),
    ),
  },
);

Action createAction() => Action(
      description: 'delay',
      action: (machine, arg) async {
        await Future<void>.delayed(Duration(seconds: arg as int));
        print(machine.activeStateId);
      },
    );

void main() {
  group('Asynchronous state change tests.', () {
    test('Async Test 1', () async {
      await m1.start();
      unawaited(m1.fire(E.change, arg: 0));
      print('Active state: ${m1.activeStateId}');
      unawaited(m1.fire(E.change, arg: 0));
      print('Active state: ${m1.activeStateId}');
      unawaited(m1.fire(E.change, arg: 0));
      print('Active state: ${m1.activeStateId}');
      unawaited(m1.fire(E.change, arg: 0));
      print('Active state: ${m1.activeStateId}');
    });
  });
}
