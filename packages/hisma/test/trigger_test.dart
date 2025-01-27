import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

import '../example/06_triggers.dart';

void main() async {
  group('Trigger tests', () {
    group(
      '0 defined',
      () {
        test('test 1: 0 defined', () async {
          final c = Checker(entryConnectorsNone);
          await c.fir([SC.s1, SC.s1, SC.s1, SC.s1, SC.s1, SC.s1, SC.s1, SC.s1]);
        });
      },
    );

    group(
      '1 defined',
      () {
        test('source', () async {
          final c = Checker(entryConnectorsSource);
          await c.fir([SC.s1, SC.s1, SC.s1, SC.s1, SC.s2, SC.s2, SC.s2, SC.s2]);
        });
        test('event', () async {
          final c = Checker(entryConnectorsEvent);
          await c.fir([SC.s1, SC.s1, SC.s2, SC.s2, SC.s1, SC.s1, SC.s2, SC.s2]);
        });
        test('transition', () async {
          final c = Checker(entryConnectorsTransition);
          await c.fir([SC.s1, SC.s2, SC.s1, SC.s2, SC.s1, SC.s2, SC.s1, SC.s2]);
        });
      },
    );

    group(
      '2 defined',
      () {
        test('source, event', () async {
          final c = Checker(entryConnectorsSourceEvent);
          await c.fir([SC.s1, SC.s1, SC.s2, SC.s2, SC.s3, SC.s3, SC.s4, SC.s4]);
        });
        test('source, transition', () async {
          final c = Checker(entryConnectorsSourceTransition);
          await c.fir([SC.s1, SC.s2, SC.s1, SC.s2, SC.s3, SC.s4, SC.s3, SC.s4]);
        });
        test('event, transition', () async {
          final c = Checker(entryConnectorsEventTransition);
          await c.fir([SC.s1, SC.s2, SC.s3, SC.s4, SC.s1, SC.s2, SC.s3, SC.s4]);
        });
      },
    );

    group(
      '3 defined',
      () {
        test('all 3 defined', () async {
          final c = Checker(entryConnectorsSourceEventTransition);
          await c.fir([SC.s1, SC.s2, SC.s3, SC.s4, SC.s5, SC.s6, SC.s7, SC.s8]);
        });
      },
    );
  });
}

class Checker {
  Checker(this.entryConnectors) {
    _prepMachine();
  }

  final Map<Trigger<SP, EP, TP>, SC> entryConnectors;
  late Machine<SP, EP, TP> _parentMachine;
  late Machine<SC, EC, TC> _childMachine;

  Future<void> _prepMachine() async {
    _parentMachine = createParentMachine(entryConnectors);
    await _parentMachine.start();
    expect(_parentMachine.activeStateId, SP.a);
    _childMachine = _parentMachine.find<SC, EC, TC>(childMachineName);
  }

  Future<void> fir(List<SC> expected) async {
    Future<void> fireA(EP event, TP transition, SC expected) async {
      await _parentMachine.fire(event, arg: transition);
      expect(_parentMachine.activeStateId, SP.c);
      expect(_childMachine.activeStateId, expected);

      await _parentMachine.fire(EP.back);
      expect(_parentMachine.activeStateId, SP.a);
    }

    Future<void> fireB(EP event, TP transition, SC expected) async {
      await _parentMachine.fire(EP.go);
      expect(_parentMachine.activeStateId, SP.b);
      await fireA(event, transition, expected);
    }

    await fireA(EP.fwd1, TP.toC1, expected[0]); // a, fwd1, T1
    await fireA(EP.fwd1, TP.toC2, expected[1]); // a, fwd1, T2
    await fireA(EP.fwd2, TP.toC1, expected[2]); // a, fwd2, T1
    await fireA(EP.fwd2, TP.toC2, expected[3]); // a, fwd2, T2

    await fireB(EP.fwd1, TP.toC1, expected[4]); // b, fwd1, T1
    await fireB(EP.fwd1, TP.toC2, expected[5]); // b, fwd1, T2
    await fireB(EP.fwd2, TP.toC1, expected[6]); // b, fwd2, T1
    await fireB(EP.fwd2, TP.toC2, expected[7]); // b, fwd2, T2
  }
}
