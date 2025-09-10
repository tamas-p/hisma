import 'package:hisma/hisma.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../example/others/entrypoint_exitpoint.dart';

void main() {
  // initLogging();
  group('Hisma monitor', () {
    test(
      'Test 1',
      () async {
        final checker = Checker();
        Machine.monitorCreators = [
          (machine) => TestMonitor(machine, checker),
        ];

        const mn = 'm1';
        checker(mn, null, null);
        final m1 = createSimpleMachine(mn);
        checker(mn, 1, null);

        await m1.start();
        checker(mn, 1, 1);

        await m1.fire(E1.change);
        checker(mn, 1, 2);

        for (var i = 0; i < 100; i++) {
          await m1.fire(E1.change);
        }
        checker(mn, 1, 102);

        await m1.fire(E1.finish);
        checker(mn, 1, 103);
      },
    );
  });

  test(
    'Monitor compound',
    () async {
      final checker = Checker();
      Machine.monitorCreators = [
        (machine) => TestMonitor(machine, checker),
        // (m) => VisualMonitor(m),
      ];

      const l0 = 'l0';
      const l1 = 'l1';
      const l2 = 'l2';
      const l3 = 'l3';

      final m = createMachine(
        name: l0,
        child: createMachine(
          name: l1,
          child: createMachine(
            name: l2,
            child: createMachine(
              name: l3,
            ),
          ),
        ),
      );

      checker(l0, 1, null);
      checker(l1, 1, null);
      checker(l2, 1, null);
      checker(l3, 1, null);

      await m.start();

      // Only to ensure that the event loop processed the ongoing notifications.
      // This is needed since Machine do not wait the notifyStateChange.
      // await Future<void>.delayed(Duration.zero);

      checker(l0, 1, 1);
      checker(l1, 1, null);
      checker(l2, 1, null);
      checker(l3, 1, null);

      await m.fire(E.deep);
      checker(l0, 1, 5);
      checker(l1, 1, 3);
      checker(l2, 1, 2);
      checker(l3, 1, 1);

      await m.find<S, E, T>(l3).fire(E.next);
      checker(l0, 1, 6);
      checker(l1, 1, 4);
      checker(l2, 1, 3);
      checker(l3, 1, 2);

      await m.find<S, E, T>(l2).fire(E.next);
      checker(l0, 1, 8);
      checker(l1, 1, 6);
      checker(l2, 1, 5);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l2).fire(E.next);
      checker(l0, 1, 9);
      checker(l1, 1, 7);
      checker(l2, 1, 6);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.next);
      checker(l0, 1, 11);
      checker(l1, 1, 9);
      checker(l2, 1, 7);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.next);
      checker(l0, 1, 12);
      checker(l1, 1, 10);
      checker(l2, 1, 7);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.exit);
      checker(l0, 1, 15);
      checker(l1, 1, 13); // S.a -> S.b, S.b -> S.c
      checker(l2, 1, 8); // S.ep4 -> S.ex
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.next);
      checker(l0, 1, 16);
      checker(l1, 1, 14);
      checker(l2, 1, 8);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.next);
      checker(l0, 1, 18);
      checker(l1, 1, 16);
      checker(l2, 1, 9);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.next);
      expect(m.find<S, E, T>(l1).activeStateId, equals(S.c));
      checker(l0, 1, 20);
      checker(l1, 1, 18);
      checker(l2, 1, 10);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.next);
      expect(m.find<S, E, T>(l1).activeStateId, equals(S.a));
      checker(l0, 1, 21);
      checker(l1, 1, 19);
      checker(l2, 1, 10);
      checker(l3, 1, 3);

      await m.find<S, E, T>(l1).fire(E.inside);
      expect(m.find<S, E, T>(l1).activeStateId, equals(S.b));
      checker(l0, 1, 24);
      checker(l1, 1, 22);
      checker(l2, 1, 12);
      checker(l3, 1, 4);

      await m.find<S, E, T>(l1).fire(E.next);
      expect(m.find<S, E, T>(l1).activeStateId, equals(S.c));
      checker(l0, 1, 27);
      checker(l1, 1, 25);
      checker(l2, 1, 14);
      checker(l3, 1, 5);

      await m.find<S, E, T>(l1).fire(E.next);
      expect(m.find<S, E, T>(l1).activeStateId, equals(S.a));
      checker(l0, 1, 28);
      checker(l1, 1, 26);
      checker(l2, 1, 14);
      checker(l3, 1, 5);

      await m.find<S, E, T>(l1).fire(E.finish);
      expect(m.find<S, E, T>(l0).activeStateId, equals(S.b));
      expect(m.find<S, E, T>(l1).activeStateId, equals(S.b));
      expect(m.find<S, E, T>(l2).activeStateId, equals(null));
      expect(m.find<S, E, T>(l3).activeStateId, equals(null));
      checker(l0, 1, 30);
      checker(l1, 1, 28);
      checker(l2, 1, 15);
      checker(l3, 1, 5);

      await m.find<S, E, T>(l0).fire(E.next);
      expect(m.find<S, E, T>(l0).activeStateId, equals(S.c));
      expect(m.find<S, E, T>(l1).activeStateId, equals(null));
      expect(m.find<S, E, T>(l2).activeStateId, equals(null));
      expect(m.find<S, E, T>(l3).activeStateId, equals(null));
      checker(l0, 1, 32);
      checker(l1, 1, 29);
      checker(l2, 1, 15);
      checker(l3, 1, 5);

      await m.find<S, E, T>(l0).fire(E.done);
      expect(m.find<S, E, T>(l0).activeStateId, equals(null));
      expect(m.find<S, E, T>(l1).activeStateId, equals(null));
      expect(m.find<S, E, T>(l2).activeStateId, equals(null));
      expect(m.find<S, E, T>(l3).activeStateId, equals(null));
      checker(l0, 1, 33);
      checker(l1, 1, 29);
      checker(l2, 1, 15);
      checker(l3, 1, 5);
    },
  );
}

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
}

enum S1 { a, b, end }

enum E1 { change, finish }

enum T1 { toA, toB, toEnd }

Machine<S1, E1, T1> createSimpleMachine(String name) => Machine<S1, E1, T1>(
      name: name,
      initialStateId: S1.a,
      states: {
        S1.a: State(
          etm: {
            E1.change: [T1.toB],
          },
        ),
        S1.b: State(
          etm: {
            E1.change: [T1.toA],
            E1.finish: [T1.toEnd],
          },
        ),
        S1.end: FinalState(),
      },
      transitions: {
        T1.toA: Transition(to: S1.a),
        T1.toB: Transition(to: S1.b),
        T1.toEnd: Transition(to: S1.end),
      },
    );

class TestMonitor implements Monitor {
  TestMonitor(this.machine, this._checker);
  final Machine<dynamic, dynamic, dynamic> machine;
  final Checker _checker;

  @override
  Future<void> notifyCreation() async {
    final value = _checker.createCounterMap[machine.name];
    _checker.createCounterMap[machine.name] = value == null ? 1 : value + 1;
  }

  @override
  Future<void> notifyStateChange() async {
    final value = _checker.changeCounterMap[machine.name];
    _checker.changeCounterMap[machine.name] = value == null ? 1 : value + 1;
  }
}

class Checker {
  final createCounterMap = <String, int>{};
  final changeCounterMap = <String, int>{};

  void call(String name, int? create, int? change) {
    expect(createCounterMap[name], equals(create));
    expect(changeCounterMap[name], equals(change));
  }
}
