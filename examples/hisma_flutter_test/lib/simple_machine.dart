import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { a, b, c, d }

enum E { forward, back, self }

enum T { toA, toB, toC, toD }

const testMachineName = 'testMachine';
StateMachineWithChangeNotifier<S, E, T> createSimpleMachine({
  bool hierarchical = false,
  int level = 0,
}) =>
    StateMachineWithChangeNotifier<S, E, T>(
      name: '$testMachineName$level',
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
            E.back: [T.toD],
            E.self: [T.toA],
          },
        ),
        S.b: State(
          etm: {
            E.forward: [T.toC],
            E.back: [T.toA],
            E.self: [T.toB],
          },
        ),
        S.c: State(
          etm: {
            E.forward: [T.toD],
            E.back: [T.toB],
            E.self: [T.toC],
          },
        ),
        S.d: State(
          etm: {
            E.forward: [T.toA],
            E.back: [T.toC],
            E.self: [T.toD],
          },
          regions: [
            if (hierarchical && level < 2)
              Region<S, E, T, S>(
                machine: createSimpleMachine(
                  hierarchical: hierarchical,
                  level: level + 1,
                ),
              ),
          ],
        ),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
        T.toC: Transition(to: S.c),
        T.toD: Transition(to: S.d),
      },
    );
