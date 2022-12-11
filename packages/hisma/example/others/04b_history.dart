// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum S { on, off }

enum E { on, off }

enum T { toOn, toOff }

final l1 = StateMachine<S, E, T>(
  name: 'l1',
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
    ),
  },
  transitions: {
    T.toOn: Transition(to: S.on),
    T.toOff: Transition(to: S.off),
  },
);

final l2 = l1.copyWith(name: 'l2', history: HistoryLevel.deep);
final l3 = l1.copyWith(name: 'l3');
final l4 = l1.copyWith(name: 'l4');
final l5 = l1.copyWith(name: 'l5');

void main(List<String> args) {
  initLogging();
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  (l4.states[S.on] as State?)?.addRegion(Region<S, E, T, S>(machine: l5));
  (l3.states[S.on] as State?)?.addRegion(Region<S, E, T, S>(machine: l4));
  (l2.states[S.on] as State?)?.addRegion(Region<S, E, T, S>(machine: l3));
  (l1.states[S.on] as State?)?.addRegion(Region<S, E, T, S>(machine: l2));

  l1.start();
}
