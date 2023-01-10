// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '02_compound_single_region.dart' as bm;
import '03_compound_multiple_regions.dart' as cm;

enum S { epGrid, epBattery, grid, battery, exDown }

enum E { change, down }

enum T { toGrid, toBattery, toDown }

const powerMachineName = 'powerMachine';

StateMachine<S, E, T> createPowerMachine() => StateMachine<S, E, T>(
      name: powerMachineName,
      events: E.values,
      initialStateId: S.grid,
      states: {
        S.epGrid: EntryPoint([T.toGrid, T.toBattery]),
        S.epBattery: EntryPoint([T.toBattery]),
        S.exDown: ExitPoint(),
        S.grid: State(
          etm: {
            E.change: [T.toBattery],
            E.down: [T.toDown],
          },
          onEntry: Action(
            description: 'Switching to grid.',
            action: (machine, parameter) async => print('GRID'),
          ),
        ),
        S.battery: State(
          etm: {
            E.change: [T.toGrid],
            E.down: [T.toDown],
          },
          onEntry: Action(
            description: 'Switching to battery.',
            action: (machine, parameter) async => print('BATTERY'),
          ),
        ),
      },
      transitions: {
        T.toBattery: Transition(to: S.battery, priority: 100),
        T.toGrid: Transition(to: S.grid),
        T.toDown: Transition(to: S.exDown),
      },
    );

enum LMS { on, off }

enum LME { turnOnGrid, turnOff, turnOnBattery }

enum LMT { toOn, toOff }

StateMachine<LMS, LME, LMT> createLightMachine({
  RegionList<LMS, LME, LMT>? regions,
}) =>
    StateMachine<LMS, LME, LMT>(
      name: 'lightMachine',
      events: LME.values,
      initialStateId: LMS.off,
      states: {
        LMS.off: State(
          etm: {
            LME.turnOnGrid: [LMT.toOn],
            LME.turnOnBattery: [LMT.toOn],
          },
          onEntry: Action(
            description: 'Turning off.',
            action: (machine, parameter) async => print('OFF'),
          ),
        ),
        LMS.on: State(
          etm: {
            LME.turnOff: [LMT.toOff],
          },
          regions: regions,
          onEntry: Action(
            description: 'Turning on.',
            action: (machine, parameter) async => print('ON'),
          ),
        ),
      },
      transitions: {
        LMT.toOn: Transition(to: LMS.on),
        LMT.toOff: Transition(to: LMS.off),
      },
    );

final lightMachine = createLightMachine(
  regions: [
    Region(machine: bm.createBrightnessMachine()),
    Region(machine: cm.createColorMachine()),
    Region(
      machine: createPowerMachine(),
      entryConnectors: {
        Trigger(
          source: LMS.off,
          event: LME.turnOnGrid,
          // TODO: In case of null it shall be any transition.
          // transition: null,
          transition: LMT.toOn,
        ): S.epGrid,
        Trigger(
          source: LMS.off,
          event: LME.turnOnBattery,
          transition: LMT.toOn,
        ): S.epBattery,
      },
      exitConnectors: {S.exDown: LME.turnOff},
    ),
  ],
);

Future<void> play() async {
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine.fire(LME.turnOnBattery);

    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine.find<S, E, T>(powerMachineName).fire(E.down);

    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine.fire(LME.turnOnGrid);

    await Future<void>.delayed(const Duration(seconds: 1));
    await lightMachine.find<S, E, T>(powerMachineName).fire(E.down);
  }
}

Future<void> main() async {
  // initLogging();
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  await lightMachine.start();
  // play();
}
