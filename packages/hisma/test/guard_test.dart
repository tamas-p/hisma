import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { a, b }

enum E { sync, async, syncEx, asyncEx, back }

enum T { syncToBex, asyncToBex, syncToBonError, asyncToBonError, back }

typedef AsyncFunction = Future<int> Function();

StateMachine<S, E, T> createMachine() => StateMachine<S, E, T>(
      name: 'guard',
      data: false,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.sync: [T.syncToBonError],
            E.async: [T.asyncToBonError],
            E.syncEx: [T.syncToBex],
            E.asyncEx: [T.asyncToBex],
          },
        ),
        S.b: State(
          etm: {
            E.back: [T.back],
          },
        ),
      },
      transitions: {
        T.back: Transition(to: S.a),
        T.syncToBex: Transition(
          to: S.b,
          guard: Guard(
            description: 'only if data > 10',
            condition: (machine, data) {
              return data is int && data > 10;
            },
          ),
        ),
        T.asyncToBex: Transition(
          to: S.b,
          guard: Guard(
            description: 'only if data > 10',
            condition: (machine, data) async {
              return data is AsyncFunction && await data() > 10;
            },
          ),
        ),
        T.syncToBonError: Transition(
          to: S.b,
          guard: Guard(
            description: 'only if data > 10',
            condition: (machine, data) {
              return data is int && data > 10;
            },
          ),
          onError: OnErrorAction(
            description: 'Set data to true.',
            action: (machine, data) async {
              await Future<void>.delayed(Duration.zero);
              expect(data.source, OnErrorSource.guard);
              machine.data = true;
            },
          ),
        ),
        T.asyncToBonError: Transition(
          to: S.b,
          guard: Guard(
            description: 'only if data > 10',
            condition: (machine, data) async {
              return data is AsyncFunction && await data() > 10;
            },
          ),
          onError: OnErrorAction(
            description: 'Set data to true.',
            action: (machine, data) {
              expect(data.source, OnErrorSource.guard);
              machine.data = true;
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
    test('Guard synchronous - Exception', () async {
      await machine.start();
      expect(machine.data as bool, false);
      expect(machine.activeStateId, S.a);

      expect(
        machine.fire(E.syncEx),
        throwsA(const TypeMatcher<HismaGuardException>()),
      );
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, false);

      expect(
        machine.fire(E.syncEx, arg: 10),
        throwsA(const TypeMatcher<HismaGuardException>()),
      );
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, false);

      await machine.fire(E.sync, arg: 11);
      expect(machine.activeStateId, S.b);
      expect(machine.data as bool, false);
    });

    test('Guard synchronous - onError', () async {
      await machine.start();
      expect(machine.data as bool, false);
      expect(machine.activeStateId, S.a);

      await machine.fire(E.sync);
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, true);

      machine.data = false;
      await machine.fire(E.sync, arg: 10);
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, true);

      machine.data = false;
      await machine.fire(E.sync, arg: 11);
      expect(machine.activeStateId, S.b);
      expect(machine.data as bool, false);
    });
    test('Guard asynchronous - Exception', () async {
      await machine.start();
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, false);

      expect(
        machine.fire(E.asyncEx),
        throwsA(const TypeMatcher<HismaGuardException>()),
      );
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, false);

      expect(
        machine.fire(E.asyncEx, arg: () => Future.value(10)),
        throwsA(const TypeMatcher<HismaGuardException>()),
      );
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, false);

      await machine.fire(E.asyncEx, arg: () => Future.value(11));
      expect(machine.activeStateId, S.b);
      expect(machine.data as bool, false);
    });
    test('Guard asynchronous - onError', () async {
      await machine.start();
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, false);

      machine.data = false;
      await machine.fire(E.async);
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, true);

      machine.data = false;
      await machine.fire(E.async, arg: () => Future.value(10));
      expect(machine.activeStateId, S.a);
      expect(machine.data as bool, true);

      machine.data = false;
      await machine.fire(E.async, arg: () => Future.value(11));
      expect(machine.activeStateId, S.b);
      expect(machine.data as bool, false);
    });
  });
}
