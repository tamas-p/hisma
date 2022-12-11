// ignore_for_file: file_names, avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

final emptyMachine = StateMachine(
  name: 'empty',
  initialStateId: null,
  states: {},
  transitions: {},
);

enum S { work, finish }

enum E { go }

enum T { toFinish, toWork }

final minimalMachine = StateMachine(
  events: E.values,
  name: 'onActions',
  initialStateId: S.work,
  states: {
    S.work: State(
      etm: {
        E.go: [T.toFinish],
      },
      onEntry: Action(
        description: 'say that we enter',
        action: (machine, parameter) async => print('we enter'),
      ),
      onExit: Action(
        description: 'say that we leave',
        action: (machine, parameter) async => print('we leave'),
      ),
    ),
    S.finish: FinalState(),
  },
  transitions: {
    T.toFinish: Transition(to: S.finish),
  },
);

final guardsMachine = StateMachine(
  events: E.values,
  name: 'guards',
  initialStateId: S.work,
  states: {
    S.work: State(
      etm: {
        E.go: [T.toWork, T.toFinish],
      },
    ),
    S.finish: FinalState(),
  },
  transitions: {
    T.toWork: Transition(
      to: S.work,
      guard: Guard(
        description: 'only if inside of working hours',
        condition: () {
          final now = DateTime.now();
          if (now.hour >= 9 && now.hour <= 17) {
            return true;
          } else {
            return false;
          }
        },
      ),
    ),
    T.toFinish: Transition(
      to: S.finish,
      guard: Guard(
        description: 'only if outside of working hours',
        condition: () {
          final now = DateTime.now();
          if (now.hour < 9 || now.hour > 17) {
            return true;
          } else {
            return false;
          }
        },
      ),
    ),
  },
);

Future<void> main(List<String> args) async {
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
  ];

  emptyMachine.activeStateId;
  minimalMachine.start();
  guardsMachine.start();
}
