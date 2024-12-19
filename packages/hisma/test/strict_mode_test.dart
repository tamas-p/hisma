import 'package:hisma/hisma.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('StateMachine assertions.', () {
    group('Default strict mode.', () {
      testAll(matcher: isA<AssertionError>());
    });

    group('Strict mode set to true.', () {
      group('At class level.', () {
        testAll(cStrict: true, matcher: isA<AssertionError>());
      });
      group('At object level.', () {
        testAll(oStrict: true, matcher: isA<AssertionError>());
      });
      group('Object level has preference.', () {
        testAll(cStrict: false, oStrict: true, matcher: isA<AssertionError>());
      });
    });

    group('Strict mode is set to false.', () {
      group('At class level.', () {
        testAll(cStrict: false);
      });
      group('At object level.', () {
        testAll(oStrict: false);
      });
      group('Object level has preference.', () {
        testAll(cStrict: true, oStrict: false);
      });
    });
  });
}

enum S { a, b, c }

enum E { forward, backward }

enum T { toA, toB, toC }

StateMachine<S, E, T> createMachine({bool? strict}) => StateMachine<S, E, T>(
      name: 'testMachine',
      strict: strict,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: State(
          etm: {
            E.backward: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
      },
    );

Future<void> testFireOnInactive({
  bool? cStrict,
  bool? oStrict,
  Object? matcher,
}) async {
  test('Fire event on an inactive machine.', () async {
    if (cStrict != null) StateMachine.strict = cStrict;
    final m = createMachine(strict: oStrict);
    // First fire on the inactive (not yet started) machine.
    final logOutput = captureLogOutput();
    if (matcher != null) {
      // If matcher provided expect that.
      expect(
        m.fire(E.forward),
        throwsA(matcher),
      );
    } else {
      // If matcher was not provided simple fire as we do not expect neither
      // assertion or exception to happen.
      await m.fire(E.forward);
    }
    expect(
      logOutput.toString(),
      contains('Machine "${m.name}" has not been started.'),
    );
  });
}

Future<void> testStartAnAlreadyStarted({
  bool? cStrict,
  bool? oStrict,
  Object? matcher,
}) async {
  test('Start an already started machine.', () async {
    if (cStrict != null) StateMachine.strict = cStrict;
    final m = createMachine(strict: oStrict);
    // Start the machine.
    await m.start();
    // Try starting the already started machine.
    final logOutput = captureLogOutput();
    if (matcher != null) {
      expect(
        m.start(),
        throwsA(matcher),
      );
    } else {
      await m.start();
    }
    expect(
      logOutput.toString(),
      contains('Machine (testMachine) is already started.'),
    );
  });
}

Future<void> testFireNotHandledEvent({
  bool? cStrict,
  bool? oStrict,
  Object? matcher,
}) async {
  test('Fire an event not handled in current state.', () async {
    if (cStrict != null) StateMachine.strict = cStrict;
    final m = createMachine(strict: oStrict);
    await m.start();
    // Fire an event that is handled in the initial state.
    await m.fire(E.forward);
    // Fire an event that is NOT handled in the current state of the machine.
    final logOutput = captureLogOutput();
    if (matcher != null) {
      expect(
        m.fire(E.forward),
        throwsA(matcher),
      );
    } else {
      await m.fire(E.forward);
    }
    expect(
      logOutput.toString(),
      contains(
        'Could not find transition ID list by "E.forward" for state "S.b"',
      ),
    );
  });
}

Future<void> testWorkflow([Object? matcher]) async {
  final m = createMachine();
  // First fire on the inactive (not yet started) machine.
  if (matcher != null) {
    // If matcher provided expect that.
    expect(
      m.fire(E.forward),
      throwsA(matcher),
    );
  } else {
    // If matcher was not provided simple fire as we do not expect neither
    // assertion or exception to happen.
    await m.fire(E.forward);
  }

  // Start the machine.
  await m.start();

  // Try starting the already started machine.
  if (matcher != null) {
    expect(
      m.start(),
      throwsA(matcher),
    );
  } else {
    await m.start();
  }

  // Fire an event that is handled in the initial state.
  await m.fire(E.forward);
  // Fire an event that is NOT handled in the current state of the machine.
  if (matcher != null) {
    expect(
      m.fire(E.forward),
      throwsA(matcher),
    );
  } else {
    await m.fire(E.forward);
  }
}

StringBuffer captureLogOutput() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  final logOutput = StringBuffer();
  Logger.root.onRecord.listen((record) {
    logOutput.writeln(record.message);
  });
  return logOutput;
}

void testAll({
  bool? cStrict,
  bool? oStrict,
  Object? matcher,
}) {
  testFireOnInactive(cStrict: cStrict, oStrict: oStrict, matcher: matcher);
  testStartAnAlreadyStarted(
    cStrict: cStrict,
    oStrict: oStrict,
    matcher: matcher,
  );
  testFireNotHandledEvent(cStrict: cStrict, oStrict: oStrict, matcher: matcher);
}
