import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { a, b, c }

enum E { forward, back, self }

enum T { toA, toB, toC }

StateMachineWithChangeNotifier<S, E, T> createSimpleMachine() =>
    StateMachineWithChangeNotifier<S, E, T>(
      name: 'testMachine',
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
            E.back: [T.toC],
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
            E.forward: [T.toA],
            E.back: [T.toB],
            E.self: [T.toC],
          },
        ),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
        T.toC: Transition(to: S.c),
      },
    )..start();
