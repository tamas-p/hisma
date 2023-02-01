// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum S { on, off }

enum E { on, off }

enum T { toOn, toOff }

StateMachine<S, E, T> createMachine({
  required String name,
  HistoryLevel? history,
  StateMachine<S, E, T>? sm,
}) =>
    StateMachine<S, E, T>(
      name: name,
      history: history,
      events: E.values,
      initialStateId: S.off,
      states: {
        S.off: State(
          etm: {
            E.on: [T.toOn],
          },
        ),
        S.on: State(
          etm: {
            E.off: [T.toOff],
          },
          regions: [if (sm != null) Region(machine: sm)],
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

void main(List<String> args) {
  initLogging();
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  smNoHistory.start();
  smShallow.start();
  smDeep.start();
}
