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

final smNoHistory = createMachine(
  name: 'noHistory-l1',
  sm: createMachine(
    name: 'noHistory-l2',
    sm: createMachine(
      name: 'noHistory-l3',
    ),
  ),
);

final smShallow = createMachine(
  name: 'shallow-l1',
  sm: createMachine(
    name: 'shallow-l2',
    history: HistoryLevel.shallow,
    sm: createMachine(
      name: 'shallow-l3',
    ),
  ),
);

final smDeep = createMachine(
  name: 'deep-l1',
  sm: createMachine(
    name: 'deep-l2',
    history: HistoryLevel.deep,
    sm: createMachine(
      name: 'deep-l3',
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
