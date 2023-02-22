// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum S { on, off, stop }

enum E { turnOn, turnOff, stop, sing, dance }

enum T { toOn, toOff, toStop, sing, dance }

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
            E.dance: [T.dance, T.sing],
          },
          onEntry: Action(
            description: 'Turning off.',
            action: (machine, arg) async => print('OFF'),
          ),
        ),
        S.on: State(
          etm: {
            E.turnOff: [T.toOff],
            E.stop: [T.toStop, T.sing],
            E.sing: [T.sing],
            E.dance: [T.dance],
          },
          regions: regions,
          onEntry: Action(
            description: 'Turning on.',
            action: (machine, arg) async => print('ON'),
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
        ),
        T.dance: InternalTransition(
          onAction: Action(
            description: 'dance',
            action: (machine, arg) async {
              print('Dancing.');
            },
          ),
        ),
        T.sing: InternalTransition(
          minInterval: const Duration(seconds: 1),
          guard: Guard(
            description: 'Always do it.',
            condition: (machine, arg) async => true,
          ),
          priority: 11,
          onAction: Action(
            description: 'test internal transition',
            action: (machine, arg) async {
              print('T.sing internal transition action.');
            },
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
