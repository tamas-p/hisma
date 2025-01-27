// ignore_for_file: file_names

import 'package:hisma/hisma.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void main(List<String> args) async {
  Machine.monitorCreators = [(m) => VisualMonitor(m)];

  final m = createParentMachine(entryConnectorsSourceEventTransition);
  await m.start();
  await Future<void>.delayed(const Duration(hours: 1));
}

//------------------------------------------------------------------------------
// 0 defined
//------------------------------------------------------------------------------

final entryConnectorsNone = <Trigger<SP, EP, TP>, SC>{
  Trigger(): SC.ep1,
};

//------------------------------------------------------------------------------
// 1 defined
//------------------------------------------------------------------------------

final entryConnectorsSource = <Trigger<SP, EP, TP>, SC>{
  Trigger(source: SP.a): SC.ep1,
  Trigger(source: SP.b): SC.ep2,
};

final entryConnectorsEvent = <Trigger<SP, EP, TP>, SC>{
  Trigger(event: EP.fwd1): SC.ep1,
  Trigger(event: EP.fwd2): SC.ep2,
};

final entryConnectorsTransition = <Trigger<SP, EP, TP>, SC>{
  Trigger(transition: TP.toC1): SC.ep1,
  Trigger(transition: TP.toC2): SC.ep2,
};

//------------------------------------------------------------------------------
// 2 defined
//------------------------------------------------------------------------------

final entryConnectorsSourceEvent = <Trigger<SP, EP, TP>, SC>{
  Trigger(source: SP.a, event: EP.fwd1): SC.ep1,
  Trigger(source: SP.a, event: EP.fwd2): SC.ep2,
  Trigger(source: SP.b, event: EP.fwd1): SC.ep3,
  Trigger(source: SP.b, event: EP.fwd2): SC.ep4,
};

final entryConnectorsSourceTransition = <Trigger<SP, EP, TP>, SC>{
  Trigger(source: SP.a, transition: TP.toC1): SC.ep1,
  Trigger(source: SP.a, transition: TP.toC2): SC.ep2,
  Trigger(source: SP.b, transition: TP.toC1): SC.ep3,
  Trigger(source: SP.b, transition: TP.toC2): SC.ep4,
};

final entryConnectorsEventTransition = <Trigger<SP, EP, TP>, SC>{
  Trigger(event: EP.fwd1, transition: TP.toC1): SC.ep1,
  Trigger(event: EP.fwd1, transition: TP.toC2): SC.ep2,
  Trigger(event: EP.fwd2, transition: TP.toC1): SC.ep3,
  Trigger(event: EP.fwd2, transition: TP.toC2): SC.ep4,
};

//------------------------------------------------------------------------------
// 3 defined
//------------------------------------------------------------------------------

final entryConnectorsSourceEventTransition = <Trigger<SP, EP, TP>, SC>{
  Trigger(source: SP.a, event: EP.fwd1, transition: TP.toC1): SC.ep1,
  Trigger(source: SP.a, event: EP.fwd1, transition: TP.toC2): SC.ep2,
  Trigger(source: SP.a, event: EP.fwd2, transition: TP.toC1): SC.ep3,
  Trigger(source: SP.a, event: EP.fwd2, transition: TP.toC2): SC.ep4,
  Trigger(source: SP.b, event: EP.fwd1, transition: TP.toC1): SC.ep5,
  Trigger(source: SP.b, event: EP.fwd1, transition: TP.toC2): SC.ep6,
  Trigger(source: SP.b, event: EP.fwd2, transition: TP.toC1): SC.ep7,
  Trigger(source: SP.b, event: EP.fwd2, transition: TP.toC2): SC.ep8,
};

//------------------------------------------------------------------------------

enum SP { a, b, c }

enum EP { forward, fwd1, fwd2, go, back }

enum TP { toC1, toC2, toA, toB }

Machine<SP, EP, TP> createParentMachine(
  Map<Trigger<SP, EP, TP>, SC> entryConnectors,
) =>
    Machine<SP, EP, TP>(
      events: EP.values,
      name: 'parentMachine',
      initialStateId: SP.a,
      states: {
        SP.a: State(
          etm: {
            EP.go: [TP.toB],
            EP.forward: [TP.toC1],
            EP.fwd1: [TP.toC1, TP.toC2],
            EP.fwd2: [TP.toC1, TP.toC2],
          },
        ),
        SP.b: State(
          etm: {
            EP.fwd1: [TP.toC1, TP.toC2],
            EP.fwd2: [TP.toC1, TP.toC2],
            // EP.back: [TP.toA],
          },
        ),
        SP.c: State(
          etm: {
            EP.back: [TP.toA],
          },
          regions: [
            Region<SP, EP, TP, SC>(
              machine: createChildMachine(),
              entryConnectors: entryConnectors,
            ),
          ],
        ),
      },
      transitions: {
        TP.toC1: Transition(
          to: SP.c,
          guard: Guard(
            condition: (machine, arg) => arg is! TP || arg == TP.toC1,
            description: 'is it C1',
          ),
        ),
        TP.toC2: Transition(
          to: SP.c,
          guard: Guard(
            condition: (machine, arg) => arg is TP && arg == TP.toC2,
            description: 'is it C2',
          ),
        ),
        TP.toA: Transition(to: SP.a),
        TP.toB: Transition(to: SP.b),
      },
    );

enum SC {
  a,
  s1,
  s2,
  s3,
  s4,
  s5,
  s6,
  s7,
  s8,
  ep1,
  ep2,
  ep3,
  ep4,
  ep5,
  ep6,
  ep7,
  ep8,
}

enum EC { forward }

enum TC { toA, toS1, toS2, toS3, toS4, toS5, toS6, toS7, toS8 }

const childMachineName = 'childMachine';
Machine<SC, EC, TC> createChildMachine() => Machine<SC, EC, TC>(
      events: EC.values,
      name: childMachineName,
      initialStateId: SC.a,
      states: {
        SC.ep1: EntryPoint([TC.toS1]),
        SC.ep2: EntryPoint([TC.toS2]),
        SC.ep3: EntryPoint([TC.toS3]),
        SC.ep4: EntryPoint([TC.toS4]),
        SC.ep5: EntryPoint([TC.toS5]),
        SC.ep6: EntryPoint([TC.toS6]),
        SC.ep7: EntryPoint([TC.toS7]),
        SC.ep8: EntryPoint([TC.toS8]),
        SC.a: State(),
        SC.s1: State(),
        SC.s2: State(),
        SC.s3: State(),
        SC.s4: State(),
        SC.s5: State(),
        SC.s6: State(),
        SC.s7: State(),
        SC.s8: State(),
      },
      transitions: {
        TC.toS1: Transition(to: SC.s1),
        TC.toS2: Transition(to: SC.s2),
        TC.toS3: Transition(to: SC.s3),
        TC.toS4: Transition(to: SC.s4),
        TC.toS5: Transition(to: SC.s5),
        TC.toS6: Transition(to: SC.s6),
        TC.toS7: Transition(to: SC.s7),
        TC.toS8: Transition(to: SC.s8),
      },
    );
