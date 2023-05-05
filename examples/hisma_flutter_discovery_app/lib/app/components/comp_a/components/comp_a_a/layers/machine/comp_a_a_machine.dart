import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { l2en1, l2en2, l2en3, l2a, l2a1, l2b, l2c, l2o }

enum E { jump, forward, backward, overlay }

enum T { toL2A, toL2A1, toL2B, toL2C, toL2O }

const aL2CompMachineName = 'aL2CompMachine';

final compL2AMachineProvider = ChangeNotifierProvider(
  (ref) => StateMachineWithChangeNotifier<S, E, T>(
    events: E.values,
    name: aL2CompMachineName,
    // history: HistoryLevel.deep,
    initialStateId: S.l2a,
    states: {
      S.l2en1: HistoryEntryPoint(HistoryLevel.shallow),
      S.l2en2: HistoryEntryPoint(HistoryLevel.shallow),
      S.l2en3: HistoryEntryPoint(HistoryLevel.deep),
      S.l2a: State(
        etm: {
          E.forward: [T.toL2B],
          E.jump: [T.toL2A1],
          E.overlay: [T.toL2O],
        },
      ),
      S.l2o: State(
        etm: {
          E.backward: [T.toL2A],
          E.jump: [T.toL2C],
        },
      ),
      S.l2a1: State(
        etm: {
          E.backward: [T.toL2A],
        },
      ),
      S.l2b: State(
        etm: {
          E.forward: [T.toL2C],
          E.backward: [T.toL2A],
        },
      ),
      S.l2c: State(
        etm: {
          E.backward: [T.toL2B],
          E.jump: [T.toL2O],
        },
      ),
    },
    transitions: {
      T.toL2A: Transition(to: S.l2a),
      T.toL2O: Transition(to: S.l2o),
      T.toL2A1: Transition(to: S.l2a1),
      T.toL2B: Transition(to: S.l2b),
      T.toL2C: Transition(to: S.l2c),
    },
  ),
);
