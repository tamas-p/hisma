// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

enum S { ep1, ep3, ep4, ep2, a, b, c, fs, ex }

enum E { next, inside, finish, exit, deep, done }

enum T { toA, toB, toC, toFs, toEx }

StateMachine<S, E, T> createMachine({
  required String name,
  StateMachine<S, E, T>? child,
  dynamic data,
}) =>
    StateMachine(
      events: E.values,
      name: name,
      data: data,
      initialStateId: S.b,
      states: {
        S.ep1: EntryPoint([T.toB]),
        S.ep2: EntryPoint([T.toB]),
        S.ep3: EntryPoint([T.toFs]),
        S.ep4: EntryPoint([T.toEx]),
        S.a: State(
          etm: {
            E.next: [T.toB],
            E.inside: [T.toB],
            E.finish: [T.toB],
            E.exit: [T.toB],
            E.deep: [T.toB],
          },
          onEntry: Action(
            description: 'add',
            action: (machine, arg) {
              print(
                '${machine.name}/${machine.activeStateId} - onEntry - data: ${machine.data}, arg: $arg',
              );
              if (machine.data is int && arg is int) {
                machine.data = (machine.data as int) + arg;
              }
            },
          ),
          onExit: Action(
            description: 'subtract',
            action: (machine, arg) {
              print(
                '${machine.name}/${machine.activeStateId} - onExit - data: ${machine.data}, arg: $arg',
              );
              if (machine.data is int && arg is int) {
                machine.data = (machine.data as int) - arg;
              }
            },
          ),
        ),
        S.b: State(
          etm: {
            E.next: [T.toC],
          },
          regions: child == null
              ? []
              : [
                  Region(
                    machine: child,
                    entryConnectors: {
                      Trigger(
                        source: S.a,
                        event: E.inside,
                        transition: T.toB,
                      ): S.ep1,
                      Trigger(
                        source: S.a,
                        event: E.finish,
                        transition: T.toB,
                      ): S.ep3,
                      Trigger(
                        source: S.a,
                        event: E.exit,
                        transition: T.toB,
                      ): S.ep4,
                      Trigger(
                        source: S.a,
                        event: E.deep,
                        transition: T.toB,
                      ): S.ep2,
                      Trigger(
                        source: S.ep2,
                        event: null,
                        transition: T.toB,
                        // transition: null,
                      ): S.ep2,
                    },
                    exitConnectors: {S.ex: E.next},
                  ),
                ],
          onEntry: Action(
            description: 'add',
            action: (machine, arg) {
              print(
                '${machine.name}/${machine.activeStateId} - onEntry - data: ${machine.data}, arg: $arg',
              );
              if (machine.data is int && arg is int) {
                machine.data = (machine.data as int) + arg;
              }
            },
          ),
          onExit: Action(
            description: 'subtract',
            action: (machine, arg) {
              print(
                '${machine.name}/${machine.activeStateId} - data: ${machine.data}, arg: $arg',
              );
              if (machine.data is int && arg is int) {
                machine.data = (machine.data as int) - arg;
              }
            },
          ),
        ),
        S.c: State(
          etm: {
            E.next: [T.toA],
            E.done: [T.toFs],
          },
        ),
        S.fs: FinalState(),
        S.ex: ExitPoint(),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(
          to: S.b,
          onAction: Action(
            description: 'add',
            action: (machine, arg) {
              print(
                '${machine.name}/${machine.activeStateId} - toB Transition action @ ${machine.name}, data: ${machine.data}, arg:$arg',
              );
              if (machine.data is int && arg is int) {
                machine.data = (machine.data as int) + arg;
              }
            },
          ),
        ),
        T.toC: Transition(to: S.c),
        T.toFs: Transition(to: S.fs),
        T.toEx: Transition(to: S.ex),
      },
    );

const l0 = 'l0';
const l1 = 'l1';
const l2 = 'l2';
const l3 = 'l3';

void checkState(StateMachine<S, E, T> m, List<dynamic> id) {
  expect(m.find<S, E, T>(l0).activeStateId, equals(id[0]));
  expect(m.find<S, E, T>(l1).activeStateId, equals(id[1]));
  expect(m.find<S, E, T>(l2).activeStateId, equals(id[2]));
  expect(m.find<S, E, T>(l3).activeStateId, equals(id[3]));
}

void checkData(StateMachine<S, E, T> m, List<int> data) {
  expect(m.find<S, E, T>(l0).data, equals(data[0]));
  expect(m.find<S, E, T>(l1).data, equals(data[1]));
  expect(m.find<S, E, T>(l2).data, equals(data[2]));
  expect(m.find<S, E, T>(l3).data, equals(data[3]));
}

Future<void> main() async {
  group('Group A', () {
    test('Test 1', () async {
      final m = createMachine(
        name: l0,
        data: 0,
        child: createMachine(
          data: 100,
          name: l1,
          child: createMachine(
            data: 200,
            name: l2,
            child: createMachine(
              data: 300,
              name: l3,
            ),
          ),
        ),
      );

      var l0d = 0;
      var l1d = 100;
      var l2d = 200;
      var l3d = 300;

      // Check if machine data initialization works.
      checkData(m, [l0d, l1d, l2d, l3d]);

      await m.start(arg: 1);
      checkState(m, [S.b, S.b, S.b, S.b]);
      // Check that all 4 x S.b onEntry actions are effective.
      checkData(m, [l0d += 1, l1d += 1, l2d += 1, l3d += 1]);

      await m.fire(E.next, arg: 2);
      checkState(m, [S.c, null, null, null]);
      // Check that all 4 x S.b onExit actions are effective.
      checkData(m, [l0d -= 2, l1d -= 2, l2d -= 2, l3d -= 2]);

      await m.fire(E.next, arg: 10);
      checkState(m, [S.a, null, null, null]);
      // Check that only 1 x S.a onEntry action is effective.
      checkData(m, [l0d += 10, l1d, l2d, l3d]);

      await m.fire(E.deep, arg: -20);
      checkState(m, [S.b, S.b, S.b, S.b]);
      // Check that 1 x S.a onExit and that all 4 x S.b onEntry actions are
      // effective plus 4 x T.toB actions are effective.
      checkData(m, [
        l0d += 20 - 20 - 20,
        l1d += -20 - 20,
        l2d += -20 - 20,
        l3d += -20 - 20,
      ]);

      await m.find<S, E, T>(l3).fire(E.next, arg: 100);
      checkState(m, [S.b, S.b, S.b, S.c]);
      // Check that only 1 x S.a onExit action is effective.
      checkData(m, [l0d, l1d, l2d, l3d -= 100]);

      await m.fire(E.next, arg: 88);
      checkState(m, [S.c, null, null, null]);
      // Check that only 3 x S.b onExit actions are effective.
      checkData(m, [l0d -= 88, l1d -= 88, l2d -= 88, l3d]);

      await m.fire(E.next, arg: -32);
      checkState(m, [S.a, null, null, null]);
      // Check that only 1 x S.a onEntry action is effective.
      checkData(m, [l0d -= 32, l1d, l2d, l3d]);

      await m.fire(E.inside, arg: 232);
      checkState(m, [S.b, S.b, S.b, S.b]);
      // Check that only 1 x S.a onExit +  4 x S.b onEntry action
      // + 2 x T.toB actions are effective.
      checkData(
        m,
        [l0d += -232 + 232 + 232, l1d += 232 + 232, l2d += 232, l3d += 232],
      );

      await m.fire(E.next, arg: 88);
      checkState(m, [S.c, null, null, null]);
      // Check that only 4 x S.b onExit actions are effective.
      checkData(m, [l0d -= 88, l1d -= 88, l2d -= 88, l3d -= 88]);

      await m.fire(E.next, arg: -32);
      checkState(m, [S.a, null, null, null]);
      // Check that only 1 x S.a onEntry action is effective.
      checkData(m, [l0d -= 32, l1d, l2d, l3d]);

      await m.fire(E.exit, arg: 88);
      checkState(m, [S.c, null, null, null]);
      // Check that only 1 x S.a onExit plus 1 x T.toB action are effective.
      checkData(m, [l0d += -88 + 88, l1d, l2d, l3d]);

      await m.fire(E.next, arg: -32);
      checkState(m, [S.a, null, null, null]);
      // Check that only 1 x S.a onEntry action is effective.
      checkData(m, [l0d -= 32, l1d, l2d, l3d]);

      await m.fire(E.finish, arg: 976);
      checkState(m, [S.b, null, null, null]);
      // Check that only 1 x S.a onExit plus 1 x T.toB action plus
      // 1 x S.b onEntry action are effective.
      checkData(m, [l0d += -976 + 976 + 976, l1d, l2d, l3d]);
    });
  });
}
