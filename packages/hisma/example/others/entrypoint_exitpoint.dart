import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

Future<void> main(List<String> args) async {
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  // final sm = createMachine(name: 'sm');
  final sm = createMachine(
    name: 'l0',
    child: createMachine(
      name: 'l1',
      child: createMachine(
        name: 'l2',
        child: createMachine(
          name: 'l3',
        ),
      ),
    ),
  );

  await sm.start();
}

enum S { ep1, ep3, ep4, ep2, a, b, c, fs, ex }

enum E { next, inside, finish, exit, deep, done }

enum T { toA, toB, toC, toFs, toEx }

Machine<S, E, T> createMachine({
  required String name,
  Machine<S, E, T>? child,
}) =>
    Machine(
      events: E.values,
      name: name,
      initialStateId: S.a,
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
                        // event: null,
                        transition: T.toB,
                        // transition: null,
                      ): S.ep2,
                    },
                    exitConnectors: {S.ex: E.next},
                  ),
                ],
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
        T.toB: Transition(to: S.b),
        T.toC: Transition(to: S.c),
        T.toFs: Transition(to: S.fs),
        T.toEx: Transition(to: S.ex),
      },
    );
