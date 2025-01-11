import 'dart:async';

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:test/test.dart';

const _testName = 'another_async_stops_machine';
final _log = getLogger(_testName);

void main() {
  group('Asynchronous state change tests.', () {
    test('Async Test 1', () async {
      await m1.start();
      await m1.fire(E.change, arg: 0);
      _log.finest('Active state: ${m1.activeStateId}');
      await m1.fire(E.change, arg: 0);
      _log.finest('Active state: ${m1.activeStateId}');
      await m1.fire(E.change, arg: 0);
      _log.finest('Active state: ${m1.activeStateId}');
      await m1.fire(E.change, arg: 0);
      _log.finest('Active state: ${m1.activeStateId}');
    });
  });
}

enum S { a, b, f }

enum E { change, finish }

enum T { toA, toB, toF }

final m1 = Machine<S, E, T>(
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
        _log.finest(machine.activeStateId);
      },
    );
