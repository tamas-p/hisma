import 'package:hisma/hisma.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:test/test.dart';

void main() async {
  // initLogging();
  Machine.monitorCreators = [(m) => VisualMonitor(m)];

  late Machine<SP, EP, TP> parentMachine;
  late Machine<SC, EC, TC> childMachine;

  setUp(() async {
    parentMachine = createParentMachine();
    await parentMachine.start();
    expect(parentMachine.activeStateId, SP.a);
    childMachine = parentMachine.find<SC, EC, TC>(childMachineName);
  });
  group('Trigger tests, source SP.a', () {
    test('test 1: (SP.a, EP.fwd1, TP.toC1)', () async {
      await parentMachine.fire(EP.fwd1, arg: true);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s1);
    });
    test('test 2: (SP.a, EP.fwd1, TP.toC2)', () async {
      await parentMachine.fire(EP.fwd1, arg: false);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s2);
    });
    test('test 3: (SP.a, EP.fwd2, TP.toC1)', () async {
      await parentMachine.fire(EP.fwd2, arg: true);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s3);
    });
    test('test 4: (SP.a, EP.fwd2, TP.toC2)', () async {
      await parentMachine.fire(EP.fwd2, arg: false);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s4);
    });
  });

  group('Trigger tests, source SP.b', () {
    setUp(() async {
      await parentMachine.fire(EP.go);
      expect(parentMachine.activeStateId, SP.b);
    });
    test('test 1: (SP.b, EP.fwd1, TP.toC1)', () async {
      await parentMachine.fire(EP.fwd1, arg: true);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s5);
    });
    test('test 2: (SP.b, EP.fwd1, TP.toC2)', () async {
      await parentMachine.fire(EP.fwd1, arg: false);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s6);
    });
    test('test 3: (SP.b, EP.fwd2, TP.toC1)', () async {
      await parentMachine.fire(EP.fwd2, arg: true);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s7);
    });
    test('test 4: (SP.b, EP.fwd2, TP.toC2)', () async {
      await parentMachine.fire(EP.fwd2, arg: false);
      expect(parentMachine.activeStateId, SP.c);
      expect(childMachine.activeStateId, SC.s8);
    });
  });
}

enum SP { a, b, c }

enum EP { fwd1, fwd2, go }

enum TP { toC1, toC2, toB }

Machine<SP, EP, TP> createParentMachine() => Machine<SP, EP, TP>(
      events: EP.values,
      name: 'parentMachine',
      initialStateId: SP.a,
      states: {
        SP.a: State(
          etm: {
            EP.go: [TP.toB],
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
        SP.c: State(
          regions: [
            Region<SP, EP, TP, SC>(
              machine: createChildMachine(),
              entryConnectors: {
                Trigger(source: SP.a, event: EP.fwd1, transition: TP.toC1):
                    SC.ep1,
                Trigger(source: SP.a, event: EP.fwd1, transition: TP.toC2):
                    SC.ep2,
                Trigger(source: SP.a, event: EP.fwd2, transition: TP.toC1):
                    SC.ep3,
                Trigger(source: SP.a, event: EP.fwd2, transition: TP.toC2):
                    SC.ep4,
                Trigger(source: SP.b, event: EP.fwd1, transition: TP.toC1):
                    SC.ep5,
                Trigger(source: SP.b, event: EP.fwd1, transition: TP.toC2):
                    SC.ep6,
                Trigger(source: SP.b, event: EP.fwd2, transition: TP.toC1):
                    SC.ep7,
                Trigger(source: SP.b, event: EP.fwd2, transition: TP.toC2):
                    SC.ep8,
              },
            ),
          ],
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
            condition: (machine, arg) => !(arg as bool),
            description: 'enabled',
          ),
        ),
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
