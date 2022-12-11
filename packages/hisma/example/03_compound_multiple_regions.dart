// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '01_simple.dart' as lm;
import '02_compound_single_region.dart' as bm;

enum S { blue, red }

enum E { change }

enum T { toBlue, toRed }

const colorMachineName = 'colorMachine';

StateMachine<S, E, T> createColorMachine() => StateMachine<S, E, T>(
      name: colorMachineName,
      events: E.values,
      initialStateId: S.blue,
      states: {
        S.blue: State(
          etm: {
            E.change: [T.toRed],
          },
          onEntry: Action(
            description: 'Turning blue.',
            action: (machine, parameter) async => print('BLUE'),
          ),
        ),
        S.red: State(
          etm: {
            E.change: [T.toBlue],
          },
          onEntry: Action(
            description: 'Turning red.',
            action: (machine, parameter) async => print('RED'),
          ),
        ),
      },
      transitions: {
        T.toRed: Transition(to: S.red),
        T.toBlue: Transition(to: S.blue),
      },
    );

final lightMachine = lm.createLightMachine(
  regions: [
    Region(machine: bm.createBrightnessMachine()),
    Region(machine: createColorMachine()),
  ],
);

Future<void> play() async {
  await Future<void>.delayed(const Duration(seconds: 1));
  await lightMachine.fire(lm.E.turnOn);

  await lightMachine.find<S, E, T>(colorMachineName).fire(E.change);

  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine
        .find<bm.S, bm.E, bm.T>(bm.brightnessMachineName)
        .fire(bm.E.change);
    await lightMachine.find<S, E, T>(colorMachineName).fire(E.change);
    await Future<void>.delayed(const Duration(seconds: 1));

    await lightMachine
        .find<bm.S, bm.E, bm.T>(bm.brightnessMachineName)
        .fire(bm.E.change);
    await lightMachine.find<S, E, T>(colorMachineName).fire(E.change);
  }

  await Future<void>.delayed(const Duration(seconds: 1));
  await lightMachine.fire(lm.E.turnOff);
}

Future<void> main() async {
  // initLogging();
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  await lightMachine.start();
  while (true) {
    await play();
  }
}
