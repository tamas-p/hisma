import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { fa, fb, fc }

enum E { forward, backward }

enum T { toA, toB, toC }

final compFMachineProvider = Provider(
  (ref) => StateMachineWithChangeNotifier<S, E, T>(
    events: E.values,
    name: 'fCompMachine',
    history: HistoryLevel.shallow,
    initialStateId: S.fa,
    states: {
      S.fa: State(
        etm: {
          E.forward: [T.toB],
        },
      ),
      S.fb: State(
        etm: {
          E.forward: [T.toC],
          E.backward: [T.toA],
        },
      ),
      S.fc: State(
        etm: {
          E.backward: [T.toB],
        },
      ),
    },
    transitions: {
      T.toA: Transition(to: S.fa),
      T.toB: Transition(to: S.fb),
      T.toC: Transition(to: S.fc),
    },
  ),
);
