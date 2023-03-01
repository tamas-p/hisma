// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum S { on, off, stop }

enum E { turnOn, turnOff, stop, setTimer }

enum T { toOn, toOff, toStop, timedOff, timedOn }

StateMachine<S, E, T> createLightMachine({
  RegionList<S, E, T>? regions,
}) =>
    StateMachine<S, E, T>(
      name: 'lightMachine',
      events: E.values,
      initialStateId: S.off,
      states: {
        S.off: State(
          etm: {
            E.turnOn: [T.toOn],
            E.setTimer: [T.timedOn],
          },
          onEntry: Action(
            description: 'Entering off state.',
            action: (machine, arg) async => print('Entering Off.'),
          ),
          onExit: Action(
            description: 'Leaving off state.',
            action: (machine, arg) async => print('Leaving Off.'),
          ),
        ),
        S.on: State(
          etm: {
            E.turnOff: [T.toOff],
            E.stop: [T.toStop],
            E.setTimer: [T.timedOff],
          },
          regions: regions,
          onEntry: Action(
            description: 'Entering on state.',
            action: (machine, arg) async => print('Entering On state.'),
          ),
        ),
        S.stop: FinalState(),
      },
      transitions: {
        T.toOn: Transition(to: S.on),
        T.toOff: Transition(to: S.off),
        T.toStop: Transition(
          guard: Guard(
            description: 'If not empty.',
            condition: (machine, arg) async => true,
          ),
          minInterval: const Duration(seconds: 1),
          priority: 10,
          to: S.stop,
          onAction: Action(
            description: 'Closing.',
            action: (machine, arg) async => print('Closing'),
          ),
          onError: OnErrorAction(
            description: 'Print error message.',
            action: (machine, onErrorData) async => print(onErrorData.message),
          ),
        ),
        T.timedOn: InternalTransition(
          onAction: Action(
            description: 'Turn on in 3 sec.',
            action: (machine, arg) async {
              print('Initiating timer to turn on in 3 sec.');
              await Future.delayed(
                const Duration(seconds: 3),
                () {
                  print('Fire timedOn.');
                  machine.fire(E.turnOn);
                },
              );
            },
          ),
        ),
        T.timedOff: InternalTransition(
          guard: Guard(
            description: 'always',
            condition: (machine, arg) async => true,
          ),
          minInterval: const Duration(seconds: 5),
          priority: 12,
          onAction: Action(
            description: 'Turn off in 3 sec.',
            action: (machine, arg) async {
              print('Initiating timer to turn off in 3 sec.');
              await Future.delayed(
                const Duration(seconds: 3),
                () {
                  print('Fire timedOff.');
                  machine.fire(E.turnOff);
                },
              );
            },
          ),
          onError: OnErrorAction(
            description: 'Print error message.',
            action: (machine, onErrorData) async => print(onErrorData.message),
          ),
        ),
      },
    );

final lightMachine = createLightMachine();

Future<void> play() async {
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine.fire(E.turnOn);
    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine.fire(E.turnOff);
  }
}

Future<void> main() async {
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  await lightMachine.start();
  // await play();
}
