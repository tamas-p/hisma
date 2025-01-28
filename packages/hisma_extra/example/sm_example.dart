// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_extra/hisma_extra.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum StateIDs {
  s1,
  s2,
}

enum EventIDs {
  e1,
  e2,
}

enum TransitionIDs { t1 }

Future<void> main() async {
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  final sm1 = Machine<StateIDs, EventIDs, TransitionIDs>(
    name: 'SM1',
    states: {
      StateIDs.s1: State(),
    },
    transitions: {},
    initialStateId: StateIDs.s1,
  );

  final sm2 = Machine<StateIDs, EventIDs, TransitionIDs>(
    name: 'SM2',
    states: {
      StateIDs.s1: State(),
    },
    transitions: {},
    initialStateId: StateIDs.s1,
  );

  final tsm = ToggleMachine(
    name: 'toggleMachine',
    initialId: ToggleState.on,
  );
  await tsm.start();
  await tsm.toggle();

  await sm1.start();
  await sm2.start();

  print('main exited.');
}
