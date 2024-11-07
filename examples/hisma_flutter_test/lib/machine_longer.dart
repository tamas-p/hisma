import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { a, b, c, d, e, f, g, h, i }

enum E { forward, back, self, jump }

enum T { toA, toB, toC, toD, toE, toF, toG, toH, toI }

const testMachineName = 'testMachine';
StateMachineWithChangeNotifier<S, E, T> createLongerMachine({
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
            E.back: [T.toI],
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
            E.forward: [T.toE],
            E.back: [T.toC],
            E.self: [T.toD],
            E.jump: [T.toB],
          },
        ),
        S.e: State(
          etm: {
            E.forward: [T.toF],
            E.back: [T.toD],
            E.self: [T.toE],
          },
          regions: [
            if (hierarchical && level < 2)
              Region<S, E, T, S>(
                machine: createLongerMachine(
                  hierarchical: hierarchical,
                  level: level + 1,
                ),
              ),
          ],
        ),
        S.f: State(
          etm: {
            E.forward: [T.toG],
            E.back: [T.toE],
            E.self: [T.toF],
          },
        ),
        S.g: State(
          etm: {
            E.forward: [T.toH],
            E.back: [T.toF],
            E.self: [T.toG],
          },
        ),
        S.h: State(
          etm: {
            E.forward: [T.toI],
            E.back: [T.toG],
            E.self: [T.toH],
            E.jump: [T.toA],
          },
        ),
        S.i: State(
          etm: {
            E.forward: [T.toA],
            E.back: [T.toH],
            E.self: [T.toI],
          },
          regions: [
            if (hierarchical && level < 2)
              Region<S, E, T, S>(
                machine: createLongerMachine(
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
        T.toE: Transition(to: S.e),
        T.toF: Transition(to: S.f),
        T.toG: Transition(to: S.g),
        T.toH: Transition(to: S.h),
        T.toI: Transition(to: S.i),
      },
    );
