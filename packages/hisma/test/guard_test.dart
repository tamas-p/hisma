import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { a, b }

enum E { sync, async }

enum T { syncToB, asyncToB }

typedef AsyncFunction = Future<int> Function();

StateMachine<S, E, T> createMachine() => StateMachine<S, E, T>(
      name: 'guard',
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.sync: [T.syncToB],
            E.async: [T.asyncToB],
          },
        ),
        S.b: State(),
      },
      transitions: {
        T.syncToB: Transition(
          to: S.b,
          guard: Guard(
            description: 'only if data > 10',
            condition: (machine, data) async {
              return data is int && data > 10;
            },
          ),
        ),
        T.asyncToB: Transition(
          to: S.b,
          guard: Guard(
            description: 'only if data > 10',
            condition: (machine, data) async {
              return data is AsyncFunction && await data() > 10;
            },
          ),
        ),
      },
    );

void main() {
  group('Guard', () {
    late StateMachine<S, E, T> machine;
    setUp(() async {
      machine = createMachine();
    });
    test('Guard synchronous', () async {
      await machine.start();
      expect(machine.activeStateId, equals(S.a));
      await machine.fire(E.sync);
      expect(machine.activeStateId, equals(S.a));
      await machine.fire(E.sync, arg: 10);
      expect(machine.activeStateId, equals(S.a));
      await machine.fire(E.sync, arg: 11);
      expect(machine.activeStateId, equals(S.b));
    });

    test('Guard asynchronous', () async {
      await machine.start();
      expect(machine.activeStateId, equals(S.a));
      await machine.fire(E.async);
      expect(machine.activeStateId, equals(S.a));
      await machine.fire(E.async, arg: () => Future.value(10));
      expect(machine.activeStateId, equals(S.a));
      await machine.fire(E.async, arg: () => Future.value(11));
      expect(machine.activeStateId, equals(S.b));
    });
  });
}
