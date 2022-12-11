// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

enum S { on, off, stop }

enum E { turnOn, turnOff, stop }

enum T { toOn, toOff, toStop }

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
          },
          onEntry: Action(
            description: 'Turning off.',
            action: (machine, parameter) async => print('OFF'),
          ),
        ),
        S.on: State(
          etm: {
            E.turnOff: [T.toOff],
            E.stop: [T.toStop],
          },
          regions: regions,
          onEntry: Action(
            description: 'Turning on.',
            action: (machine, parameter) async => print('ON'),
          ),
        ),
        S.stop: FinalState(),
      },
      transitions: {
        T.toOn: Transition(to: S.on),
        T.toOff: Transition(to: S.off),
        T.toStop: Transition(to: S.stop),
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
  play();
}
