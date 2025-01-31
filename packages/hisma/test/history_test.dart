import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

import '../example/05_history.dart';

void main() {
  group('History tests', () {
    test('No history', () async {
      final checker =
          Checker(machine: smNoHistory(), ml1: nhl1, ml2: nhl2, ml3: nhl3);
      await checker(first: E.on, s: E.on, l1: S.on, l2: S.off, l3: null);
    });
    test('Shallow history', () async {
      final checker =
          Checker(machine: smShallow(), ml1: shl1, ml2: shl2, ml3: shl3);
      await checker(first: E.on, s: E.on, l1: S.on, l2: S.on, l3: S.off);
    });
    test('Deep history', () async {
      final checker =
          Checker(machine: smDeep(), ml1: dhl1, ml2: dhl2, ml3: dhl3);
      await checker(first: E.on, s: E.on, l1: S.on, l2: S.on, l3: S.on);
    });

    group('History endpoints', () {
      group('with E.on', () {
        test('E.on to turn on, No HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(first: E.on, s: E.on, l1: S.on, l2: S.off, l3: null);
        });
        test('E.shallow to turn on, No HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(
              first: E.shallow, s: E.on, l1: S.on, l2: S.off, l3: null);
        });
        test('E.deep to turn on, No HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(first: E.deep, s: E.on, l1: S.on, l2: S.off, l3: null);
        });
      });
      group('with E.shallow', () {
        test('E.on to turn on, Shallow HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(
              first: E.on, s: E.shallow, l1: S.on, l2: S.on, l3: S.off);
        });
        test('E.shallow to turn on, Shallow HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(
              first: E.shallow, s: E.shallow, l1: S.on, l2: S.on, l3: S.off);
        });
        test('E.deep to turn on, Shallow HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(
              first: E.deep, s: E.shallow, l1: S.on, l2: S.on, l3: S.off);
        });
      });
      group('with E.deep', () {
        test('E.onDeep to turn on, HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(first: E.on, s: E.deep, l1: S.on, l2: S.on, l3: S.on);
        });
        test('E.shallow to turn on, Deep HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(
              first: E.shallow, s: E.deep, l1: S.on, l2: S.on, l3: S.on);
        });
        test('E.deep to turn on, Deep HistoryEndpoint used', () async {
          final checker =
              Checker(machine: smHistoryEPs(), ml1: hel1, ml2: hel2, ml3: hel3);
          await checker(first: E.deep, s: E.deep, l1: S.on, l2: S.on, l3: S.on);
        });
      });
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

  Future<void> startAndTurnOnAll(E event) async {
    await machine.start();
    await machine.find<S, E, T>(ml1).fire(event);
    await machine.find<S, E, T>(ml2).fire(event);
    // For l3 we do not have shallow and deep events so we use 'on' always.
    await machine.find<S, E, T>(ml3).fire(E.on);
  }

  Future<void> call({
    required E first,
    required E s,
    required S? l1,
    required S? l2,
    required S? l3,
  }) async {
    await startAndTurnOnAll(first);
    checkResult(l1: S.on, l2: S.on, l3: S.on);
    await machine.fire(E.off);
    checkResult(l1: S.off, l2: null, l3: null);

    await machine.fire(s);
    checkResult(l1: l1, l2: l2, l3: l3);
  }

  void checkResult({required S? l1, required S? l2, required S? l3}) {
    expect(machine.find<S, E, T>(ml1).activeStateId, equals(l1));
    expect(machine.find<S, E, T>(ml2).activeStateId, equals(l2));
    expect(machine.find<S, E, T>(ml3).activeStateId, equals(l3));
  }
}
