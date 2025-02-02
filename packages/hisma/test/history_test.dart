import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

import '../example/05_history.dart';

void main() {
  group('History tests', () {
    test('No history', () async {
      final checker = Checker(smNoHistory(), nhl1, nhl2, nhl3);
      await checker(E.on, E.on, S.on, S.off, null);
    });
    test('Shallow history', () async {
      final checker = Checker(smShallow(), shl1, shl2, shl3);
      await checker(E.on, E.on, S.on, S.on, S.off);
    });
    test('Deep history', () async {
      final checker = Checker(smDeep(), dhl1, dhl2, dhl3);
      await checker(E.on, E.on, S.on, S.on, S.on);
    });

    group('History endpoints', () {
      group('with E.on', () {
        test('E.on to turn on, No HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.on, E.on, S.on, S.off, null);
        });
        test('E.shallow to turn on, No HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.shallow, E.on, S.on, S.off, null);
        });
        test('E.deep to turn on, No HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.deep, E.on, S.on, S.off, null);
        });
      });
      group('with E.shallow', () {
        test('E.on to turn on, Shallow HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.on, E.shallow, S.on, S.on, S.off);
        });
        test('E.shallow to turn on, Shallow HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.shallow, E.shallow, S.on, S.on, S.off);
        });
        test('E.deep to turn on, Shallow HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.deep, E.shallow, S.on, S.on, S.off);
        });
      });
      group('with E.deep', () {
        test('E.onDeep to turn on, HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.on, E.deep, S.on, S.on, S.on);
        });
        test('E.shallow to turn on, Deep HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.shallow, E.deep, S.on, S.on, S.on);
        });
        test('E.deep to turn on, Deep HistoryEndpoint used', () async {
          final checker = Checker(smHistoryEPs(), hel1, hel2, hel3);
          await checker(E.deep, E.deep, S.on, S.on, S.on);
        });
      });
    });
  });
}

class Checker {
  Checker(
    this.machine,
    this.machineNameL1,
    this.machineNameL2,
    this.machineNameL3,
  );

  final Machine<S, E, T> machine;
  final String machineNameL1;
  final String machineNameL2;
  final String machineNameL3;

  Future<void> startAndTurnOnAll(E event) async {
    await machine.start();
    await machine.find<S, E, T>(machineNameL1).fire(event);
    await machine.find<S, E, T>(machineNameL2).fire(event);
    // For l3 we do not have shallow and deep events so we use 'on' always.
    await machine.find<S, E, T>(machineNameL3).fire(E.on);
  }

  Future<void> call(
    E first,
    E second,
    S? expectedL1,
    S? expectedL2,
    S? expectedL3,
  ) async {
    await startAndTurnOnAll(first);
    checkResult(l1: S.on, l2: S.on, l3: S.on);
    await machine.fire(E.off);
    checkResult(l1: S.off, l2: null, l3: null);

    await machine.fire(second);
    checkResult(l1: expectedL1, l2: expectedL2, l3: expectedL3);
  }

  void checkResult({required S? l1, required S? l2, required S? l3}) {
    expect(machine.find<S, E, T>(machineNameL1).activeStateId, equals(l1));
    expect(machine.find<S, E, T>(machineNameL2).activeStateId, equals(l2));
    expect(machine.find<S, E, T>(machineNameL3).activeStateId, equals(l3));
  }
}
