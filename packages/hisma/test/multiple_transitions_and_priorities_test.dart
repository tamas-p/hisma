import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

void main() {
  group('Transition priorities test', () {
    test('Simple', () async {
      final m1 = createSimpleMachine('m1');
      await m1.start();
      expect(m1.activeStateId, equals(S.a));
      await m1.fire(E.change);
      expect(m1.activeStateId, equals(S.c));
    });

    test('With guards', () async {
      final m1 = createSimpleMachine('m1');
      final checker = Checker(m1);
      await m1.start();

      await checker({cb: false, cc: false, cd: false}, S.a);
      await checker({cb: false, cc: false, cd: true}, S.d);
      await checker({cb: false, cc: true, cd: false}, S.c);
      await checker({cb: false, cc: true, cd: true}, S.c);
      await checker({cb: true, cc: false, cd: false}, S.b);
      await checker({cb: true, cc: false, cd: true}, S.d);
      await checker({cb: true, cc: true, cd: false}, S.c);
      await checker({cb: true, cc: true, cd: true}, S.c);
    });
  });
}

enum S { a, b, c, d }

enum E { change, back }

enum T { toA, toB, toC, toD }

const cb = 'condition-b';
const cc = 'condition-c';
const cd = 'condition-d';

StateMachine<S, E, T> createSimpleMachine(String name) => StateMachine<S, E, T>(
      name: name,
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.change: [T.toB, T.toC, T.toD],
            E.back: [T.toA],
          },
        ),
        S.b: State(
          etm: {
            E.back: [T.toA],
          },
        ),
        S.c: State(
          etm: {
            E.back: [T.toA],
          },
        ),
        S.d: State(
          etm: {
            E.back: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(
          to: S.b,
          priority: 10,
          guard: Guard(
            description: cb,
            condition: (machine, arg) {
              return arg is! Map<String, bool> || (arg[cb] ?? false);
            },
          ),
          onError: OnErrorAction.noAction(),
        ),
        T.toC: Transition(
          to: S.c,
          priority: 30,
          guard: Guard(
            description: cc,
            condition: (machine, arg) {
              return arg is! Map<String, bool> || (arg[cc] ?? false);
            },
          ),
          onError: OnErrorAction.noAction(),
        ),
        T.toD: Transition(
          to: S.d,
          priority: 20,
          guard: Guard(
            description: cd,
            condition: (machine, arg) {
              return arg is! Map<String, bool> || (arg[cd] ?? false);
            },
          ),
          onError: OnErrorAction.noAction(),
        ),
      },
    );

class Checker {
  Checker(this.machine);

  final StateMachine<S, E, T> machine;

  Future<void> call(Map<String, bool> guards, S expected) async {
    expect(machine.activeStateId, equals(S.a));
    await machine.fire(E.change, arg: guards);
    expect(machine.activeStateId, equals(expected));
    await machine.fire(E.back);
    expect(machine.activeStateId, equals(S.a));
  }
}
