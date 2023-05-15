import 'package:hisma/hisma.dart';
import 'package:hisma/src/policy.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

enum S { a, b, c }

enum E { forward, backward }

enum T { toA, toB, toC }

StateMachine<S, E, T> createMachine([ReactionPolicy? policy]) =>
    StateMachine<S, E, T>(
      name: 'testMachine',
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
      policy: policy,
    );

Future<void> testWorkflow({Object? matcher, ReactionPolicy? policy}) async {
  final m = createMachine(policy);
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
  // Fire an event that is handled in the initial state.
  await m.fire(E.forward);
  // Fire an event that is NOT handled in the state machine is in.
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

void main() {
  group('ReactionPolicy.', () {
    group('Null, String and other Objects.', () {
      test('log', () {
        const policy = ReactionPolicy({Reaction.log});
        final log = Logger('test');
        final logOutput = captureLogOutput();
        policy.act(log, null);
        expect(logOutput.toString(), contains('null'));
      });
      test('Null', () {
        final logOutput = captureLogOutput();
        final log = Logger('test');
        const policy = ReactionPolicy({Reaction.log, Reaction.exception});
        expect(
          () => policy.act(log, null),
          throwsA(
            predicate(
              (e) => e is HismaMachinePolicyException && e.message == 'null',
            ),
          ),
        );
        expect(logOutput.toString(), contains('null'));
      });
      test('String', () {
        final logOutput = captureLogOutput();
        final log = Logger('test');
        const policy = ReactionPolicy({Reaction.log, Reaction.exception});
        const str = 'Simple string.';
        expect(
          () => policy.act(log, str),
          throwsA(
            predicate(
              (e) => e is HismaMachinePolicyException && e.message == str,
            ),
          ),
        );
        expect(logOutput.toString(), contains(str));
      });
      test('Integer', () {
        final logOutput = captureLogOutput();
        final log = Logger('test');
        const policy = ReactionPolicy({Reaction.log, Reaction.exception});
        expect(
          () => policy.act(log, 12),
          throwsA(
            predicate(
              (e) => e is HismaMachinePolicyException && e.message == '12',
            ),
          ),
        );
        expect(logOutput.toString(), contains('12'));
      });
    });
    group('Closure as message argument.', () {
      test('Exception.', () {
        final logOutput = captureLogOutput();
        final log = Logger('test');
        const policy = ReactionPolicy({Reaction.log, Reaction.exception});
        expect(
          () => policy.act(log, () => 'TestA ${100} End'),
          throwsA(
            predicate(
              (e) =>
                  e is HismaMachinePolicyException &&
                  e.message == 'TestA 100 End',
            ),
          ),
        );
        expect(logOutput.toString(), contains('TestA 100 End'));
      });
      test('Assertion.', () {
        final logOutput = captureLogOutput();
        final log = Logger('test');
        const policy = ReactionPolicy({Reaction.log, Reaction.assertion});
        expect(
          () => policy.act(log, () => 'TestA ${100} End'),
          throwsA(
            predicate(
              (e) => e is AssertionError && e.message == 'TestA 100 End',
            ),
          ),
        );
        expect(logOutput.toString(), contains('TestA 100 End'));
      });
    });
  });

  group('StateMachine reactions.', () {
    group(
        'Inactive machine plus not defined event tests with policy set in class.',
        () {
      test('Default policy.', () {
        testWorkflow(matcher: isA<AssertionError>());
      });
      test('Empty policy.', () async {
        StateMachine.policy = const ReactionPolicy({});
        await testWorkflow();
      });

      test('Exception policy.', () async {
        StateMachine.policy = const ReactionPolicy({Reaction.exception});
        await testWorkflow(matcher: isA<HismaMachinePolicyException>());
      });
    });
    group(
        'Inactive machine  plus not defined event tests with policy set in constructor.',
        () {
      test('Empty policy.', () {
        testWorkflow(policy: const ReactionPolicy({}));
      });

      test('Exception policy.', () {
        testWorkflow(
          matcher: isA<HismaMachinePolicyException>(),
          policy: const ReactionPolicy({Reaction.exception}),
        );
      });
    });
  });
}
