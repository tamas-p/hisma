import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import 'ui.dart';

enum S { a, b, c, d, e, f, g, h, i, j, k, l, m, n }

enum E { forward, back, self, jumpP, jumpOP, jumpI, jumpBP, fwdToException }

enum T { toA, toB, toC, toD, toE, toF, toG, toH, toI, toJ, toK, toL, toM, toN }

StateMachineWithChangeNotifier<S, E, T> createLongerMachine({
  String name = 'root',
  bool hierarchical = false,
  int level = 0,
}) =>
    StateMachineWithChangeNotifier<S, E, T>(
      name: name,
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
            E.back: [T.toK],
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
          },
        ),
        S.e: State(
          etm: {
            E.forward: [T.toF],
            E.back: [T.toD],
            E.self: [T.toE],
          },
        ),
        S.f: State(
          etm: {
            E.forward: [T.toG],
            E.back: [T.toE],
            E.self: [T.toF],
            E.jumpI: [T.toD],
          },
        ),
        S.g: State(
          etm: {
            E.forward: [T.toH],
            E.back: [T.toF],
            E.self: [T.toG],
          },
          regions: [
            if (hierarchical && level < 2)
              Region<S, E, T, S>(
                machine: createLongerMachine(
                  name: getMachineName(name, S.g),
                  hierarchical: hierarchical,
                  level: level + 1,
                ),
              ),
          ],
        ),
        S.h: State(
          etm: {
            E.forward: [T.toI],
            E.back: [T.toG],
            E.self: [T.toH],
          },
        ),
        S.i: State(
          etm: {
            E.forward: [T.toJ],
            E.back: [T.toH],
            E.self: [T.toI],
          },
        ),
        S.j: State(
          etm: {
            E.forward: [T.toK],
            E.back: [T.toI],
            E.self: [T.toJ],
            E.jumpP: [T.toC],
            E.jumpOP: [T.toG],
            E.jumpI: [T.toE],
            E.jumpBP: [T.toF],
          },
        ),
        S.k: State(
          etm: {
            E.forward: [T.toA],
            E.back: [T.toJ],
            E.self: [T.toK],
            E.jumpP: [T.toL],
          },
          regions: [
            if (hierarchical && level < 2)
              Region<S, E, T, S>(
                machine: createLongerMachine(
                  name: getMachineName(name, S.k),
                  hierarchical: hierarchical,
                  level: level + 1,
                ),
              ),
          ],
        ),
        S.l: State(
          etm: {
            E.forward: [T.toM],
            E.fwdToException: [T.toN],
            E.back: [T.toK],
            E.self: [T.toL],
          },
        ),
        S.m: State(
          etm: {
            E.back: [T.toL],
            E.self: [T.toM],
          },
        ),
        S.n: State(
          etm: {
            E.back: [T.toL],
            E.self: [T.toN],
          },
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
        T.toJ: Transition(to: S.j),
        T.toK: Transition(to: S.k),
        T.toL: Transition(to: S.l),
        T.toM: Transition(to: S.m),
        T.toN: Transition(to: S.n),
      },
    );
