import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void main() async {
  initLogging();
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    // (machine) => ConsoleMonitor(machine),
  ];
  print('started');
  final parentMachine = createParentMachine();
  await parentMachine.start();
  await Future<void>.delayed(const Duration(seconds: 1000));
  print('done');
}

enum SP { a, b, c }

enum EP { fwd1, fwd2 }

enum TP { toC1, toC2 }

Machine<SP, EP, TP> createParentMachine() => Machine<SP, EP, TP>(
      name: 'parentMachine',
      initialStateId: SP.a,
      states: {
        SP.a: State(
          etm: {
            EP.fwd1: [TP.toC1, TP.toC2],
            EP.fwd2: [TP.toC1, TP.toC2],
          },
        ),
        SP.b: State(
          etm: {
            EP.fwd1: [TP.toC1, TP.toC2],
            EP.fwd2: [TP.toC1, TP.toC2],
          },
        ),
      },
      transitions: {
        TP.toC1: Transition(
          to: SP.c,
          guard: Guard(
            condition: (machine, arg) => arg as bool,
            description: 'enabled',
          ),
        ),
        TP.toC2: Transition(
          to: SP.c,
          guard: Guard(
            condition: (machine, arg) => arg as bool,
            description: 'enabled',
          ),
        ),
      },
    );

enum SC { a, b }

enum EC { forward }

enum TC { toA, toB }

const childMachineName = 'childMachine';
Machine<SC, EC, TC> createChildMachine() => Machine<SC, EC, TC>(
      name: childMachineName,
      initialStateId: SC.a,
      states: {},
      transitions: {},
    );
