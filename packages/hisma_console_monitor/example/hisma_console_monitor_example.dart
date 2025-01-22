// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';

Future<void> main() async {
  Machine.monitorCreators = [
    (machine) => ConsoleMonitor(machine),
  ];

  await lightMachine.start();
  await play();
}

enum S { on, off }

enum E { turnOn, turnOff }

enum T { toOn, toOff }

Machine<S, E, T> createLightMachine({
  List<Region<S, E, T, dynamic>>? regions,
}) =>
    Machine<S, E, T>(
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
            action: (machine, dynamic arg) async => print('OFF'),
          ),
        ),
        S.on: State(
          etm: {
            E.turnOff: [T.toOff],
          },
          regions: regions,
          onEntry: Action(
            description: 'Turning on.',
            action: (machine, dynamic arg) async => print('ON'),
          ),
        ),
      },
      transitions: {
        T.toOn: Transition(to: S.on),
        T.toOff: Transition(to: S.off),
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
