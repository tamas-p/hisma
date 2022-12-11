import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { a, b, c }

enum E { forward, backward }

enum T { toA, toB, toC }

final compFMachineProvider = Provider(
  (ref) => StateMachineWithChangeNotifier<S, E, T>(
    events: E.values,
    name: 'fCompMachine',
    history: HistoryLevel.shallow,
    initialStateId: S.a,
    states: {
      S.a: State(
        etm: {
          E.forward: [T.toB],
        },
      ),
      S.b: State(
        etm: {
          E.forward: [T.toC],
          E.backward: [T.toA],
        },
      ),
      S.c: State(
        etm: {
          E.backward: [T.toB]
        },
      ),
    },
    transitions: {
      T.toA: Transition(to: S.a),
      T.toB: Transition(to: S.b),
      T.toC: Transition(to: S.c),
    },
  ),
);
