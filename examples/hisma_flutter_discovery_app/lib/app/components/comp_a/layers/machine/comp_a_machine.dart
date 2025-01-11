import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../layers/machine/app_machine.dart' as am;
import '../../components/comp_a_a/layers/machine/comp_a_a_machine.dart';

enum S { cen1, cen2, cen3, ca, ca1, ca2, cb, cc, fs1, fs2, fs3 }

enum E { jump, run, forward, backward, done1, done2, done3, int1 }

enum T { toCA, toCA1, toCA2, toCB, toCC, toFs1, toFs2, toFs3, int1 }

final compAMachineProvider = Provider(
  (ref) => NavigationMachine<S, E, T>(
    events: E.values,
    name: 'aCompMachine',
    history: HistoryLevel.deep,
    initialStateId: S.ca,
    states: {
      S.cen1: HistoryEntryPoint(HistoryLevel.shallow),
      S.cen2: HistoryEntryPoint(HistoryLevel.shallow),
      S.cen3: HistoryEntryPoint(HistoryLevel.deep),
      S.ca: State(
        etm: {
          E.forward: [T.toCB],
          E.jump: [T.toCA1],
          E.run: [T.toCA2],
        },
        regions: [
          Region<S, E, T, dynamic>(machine: ref.read(compL2AMachineProvider)),
        ],
      ),
      S.ca1: State(
        etm: {
          E.backward: [T.toCA],
          E.int1: [T.int1],
        },
      ),
      S.ca2: State(
        etm: {
          E.backward: [T.toCA],
        },
      ),
      S.cb: State(
        etm: {
          E.forward: [T.toCC],
          E.backward: [T.toCA],
        },
      ),
      S.cc: State(
        etm: {
          E.backward: [T.toCB],
          E.done1: [T.toFs1],
          E.done2: [T.toFs2],
          E.done3: [T.toFs3],
        },
      ),
      S.fs1: FinalState(),
      S.fs2: FinalState(),
      S.fs3: FinalState(),
    },
    transitions: {
      T.toCA: Transition(to: S.ca),
      T.toCA1: Transition(to: S.ca1),
      T.toCA2: Transition(to: S.ca2),
      T.toCB: Transition(to: S.cb),
      T.toCC: Transition(to: S.cc),
      T.toFs1: Transition(to: S.fs1),
      T.toFs2: Transition(to: S.fs2),
      T.toFs3: Transition(to: S.fs3),
      T.int1: InternalTransition(
        onAction: Action(
          description: 'int1',
          action: (machine, dynamic arg) async {
            print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1');
            final m = ref.read(am.appMachineProvider);
            await m.fire(am.E.bigJump);
          },
        ),
      )
    },
  ),
);
