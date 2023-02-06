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

final minimalMachine = StateMachine<S, E, T>(
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
        action: (machine, arg) async => print('we enter'),
      ),
      onExit: Action(
        description: 'say that we leave',
        action: (machine, arg) async => print('we leave'),
      ),
    ),
    S.finish: FinalState(),
  },
  transitions: {
    T.toFinish: Transition(to: S.finish),
  },
);

final guardsMachine = StateMachine<S, E, T>(
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
        condition: (machine, data) async {
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
        condition: (machine, data) async {
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
  await minimalMachine.start();
  await guardsMachine.start();
}
