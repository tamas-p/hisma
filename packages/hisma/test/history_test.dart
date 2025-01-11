import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

import '../example/05_history.dart';

void main() {
  group('History tests', () {
    test('No history', () async {
      final checker =
          Checker(machine: smNoHistory, ml1: nhl1, ml2: nhl2, ml3: nhl3);

      await checker.startAndTurnOnAll();
      checker(l1: S.on, l2: S.on, l3: S.on);

      await checker.turnL1Off();
      checker(l1: S.off, l2: null, l3: null);

      await checker.turnL1On();
      checker(l1: S.on, l2: S.off, l3: null);
    });
    test('Shallow history', () async {
      final checker =
          Checker(machine: smShallow, ml1: shl1, ml2: shl2, ml3: shl3);

      await checker.startAndTurnOnAll();
      checker(l1: S.on, l2: S.on, l3: S.on);

      await checker.turnL1Off();
      checker(l1: S.off, l2: null, l3: null);

      await checker.turnL1On();
      checker(l1: S.on, l2: S.on, l3: S.off);
    });
    test('Deep history', () async {
      final checker = Checker(machine: smDeep, ml1: dhl1, ml2: dhl2, ml3: dhl3);

      await checker.startAndTurnOnAll();
      checker(l1: S.on, l2: S.on, l3: S.on);

      await checker.turnL1Off();
      checker(l1: S.off, l2: null, l3: null);

      await checker.turnL1On();
      checker(l1: S.on, l2: S.on, l3: S.on);
    });
  });
}

class Checker {
  Checker({
    required this.machine,
    required this.ml1,
    required this.ml2,
    required this.ml3,
  });

  final Machine<S, E, T> machine;
  final String ml1;
  final String ml2;
  final String ml3;

  Future<void> turnL1Off() async {
    await machine.fire(E.off);
  }

  Future<void> turnL1On() async {
    await machine.fire(E.on);
  }

  Future<void> startAndTurnOnAll() async {
    await machine.start();
    await machine.find<S, E, T>(ml1).fire(E.on);
    await machine.find<S, E, T>(ml2).fire(E.on);
    await machine.find<S, E, T>(ml3).fire(E.on);
  }

  void call({required S? l1, required S? l2, required S? l3}) {
    expect(machine.find<S, E, T>(ml1).activeStateId, equals(l1));
    expect(machine.find<S, E, T>(ml2).activeStateId, equals(l2));
    expect(machine.find<S, E, T>(ml3).activeStateId, equals(l3));
  }
}
