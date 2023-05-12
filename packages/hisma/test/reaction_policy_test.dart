// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma/src/policy.dart';
import 'package:test/test.dart';

enum S { a, b, c }

enum E { forward, backward }

enum T { toA, toB, toC }

StateMachine<S, E, T> createMachine([ReactionPolicy? policy]) =>
    StateMachine<S, E, T>(
      name: 'testMachine',
      initialStateId: S.a,
      states: {},
      transitions: {},
      policy: policy,
    );

void main() {
  group('Inactive machine tests.', () {
    test('Fire on inactive machine with default policy.', () {
      final m = createMachine();
      expect(
        m.fire(E.forward),
        throwsA(isA<AssertionError>()),
      );
    });
    test('Fire on inactive machine with empty policy.', () {
      StateMachine.policy = const ReactionPolicy({});
      final m = createMachine();
      expect(m.fire(E.forward), isA<Future<void>>());
    });

    test('Fire on inactive machine with exception policy.', () {
      StateMachine.policy = const ReactionPolicy({Reaction.exception});
      final m = createMachine();
      expect(m.fire(E.forward), throwsA(isA<HismaMachinePolicyException>()));
    });
  });
  group('Inactive machine tests with StateMachine policy set.', () {
    test('Fire on inactive machine with empty policy.', () {
      final m = createMachine(const ReactionPolicy({}));
      expect(m.fire(E.forward), isA<Future<void>>());
    });

    test('Fire on inactive machine with exception policy.', () {
      final m = createMachine(const ReactionPolicy({Reaction.exception}));
      expect(m.fire(E.forward), throwsA(isA<HismaMachinePolicyException>()));
    });
  });
}
