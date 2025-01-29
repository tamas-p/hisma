// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void main(List<String> args) {
  initLogging();
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  smNoHistory.start();
  smShallow.start();
  smDeep.start();
  smHistoryEndpoints.start();
}

enum S { on, off, deep, shallow }

enum E { on, off, deep, shallow }

enum T { toOn, toOff }

Machine<S, E, T> createMachine({
  required String name,
  HistoryLevel? history,
  Machine<S, E, T>? sm,
  bool historyEPs = false,
  bool historyEVs = false,
}) =>
    Machine<S, E, T>(
      name: name,
      history: history,
      events: E.values,
      initialStateId: S.off,
      states: {
        if (historyEPs) S.shallow: HistoryEntryPoint(HistoryLevel.shallow),
        if (historyEPs) S.deep: HistoryEntryPoint(HistoryLevel.deep),
        S.off: State(
          etm: {
            E.on: [T.toOn],
            if (historyEVs) E.deep: [T.toOn],
            if (historyEVs) E.shallow: [T.toOn],
          },
        ),
        S.on: State(
          etm: {
            E.off: [T.toOff],
          },
          regions: [
            if (sm != null)
              Region(
                machine: sm,
                entryConnectors: {
                  if (historyEVs) Trigger(event: E.deep): S.deep,
                  if (historyEVs) Trigger(event: E.shallow): S.shallow,
                },
              )
          ],
        ),
      },
      transitions: {
        T.toOn: Transition(to: S.on),
        T.toOff: Transition(to: S.off),
      },
    );

const nhl1 = 'noHistory-l1';
const nhl2 = 'noHistory-l2';
const nhl3 = 'noHistory-l3';

final smNoHistory = createMachine(
  name: nhl1,
  sm: createMachine(
    name: nhl2,
    sm: createMachine(
      name: nhl3,
    ),
  ),
);

const shl1 = 'shallow-l1';
const shl2 = 'shallow-l2';
const shl3 = 'shallow-l3';

final smShallow = createMachine(
  name: shl1,
  sm: createMachine(
    name: shl2,
    history: HistoryLevel.shallow,
    sm: createMachine(
      name: shl3,
    ),
  ),
);

const dhl1 = 'deep-l1';
const dhl2 = 'deep-l2';
const dhl3 = 'deep-l3';

final smDeep = createMachine(
  name: dhl1,
  sm: createMachine(
    name: dhl2,
    history: HistoryLevel.deep,
    sm: createMachine(
      name: dhl3,
    ),
  ),
);

const hel1 = 'historyEndpoints-l1';
const hel2 = 'historyEndpoints-l2';
const hel3 = 'historyEndpoints-l3';

final smHistoryEndpoints = createMachine(
  historyEVs: true,
  name: hel1,
  sm: createMachine(
    historyEPs: true,
    historyEVs: true,
    name: hel2,
    sm: createMachine(
      historyEPs: true,
      name: hel3,
    ),
  ),
);
