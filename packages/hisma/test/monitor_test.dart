import 'package:hisma/hisma.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  Future<void> testIt(Type monitorType) async {
    late TestMonitor monitor;
    Machine.monitorCreators = [
      // (m) => ConsoleMonitor(m),
      // (m) => VisualMonitor(m),
    ];
    final m = createMachine(
      monitorCreators: [
        (m) {
          switch (monitorType) {
            case SyncMonitor:
              return monitor = SyncMonitor(m);
            case AsyncMonitor:
              return monitor = AsyncMonitor(m);
            default:
              throw ArgumentError('Monitor type is not supported by the test.');
          }
        }
      ],
    );
    await m.start();

    final expected = <Object>[
      [],
      [S.a],
      [S.b],
      [
        S.b,
        [S.a]
      ],
      [
        S.b,
        [S.b]
      ],
      [
        S.b,
        [S.c]
      ],
      [S.b],
      [S.c]
    ];
    expect(monitor.activeStateIdHistory, expected);
    await Future<void>.delayed(Duration.zero);
    expect(monitor.activeStateIdHistory, expected);
  }

  group('machine monitoring test', () {
    test(
      'SyncMonitor',
      () async {
        await testIt(SyncMonitor);
      },
    );
    test(
      'AsyncMonitor',
      () async {
        await testIt(AsyncMonitor);
      },
    );
  });
}

abstract class TestMonitor implements Monitor {
  TestMonitor(this.machine);
  Machine<dynamic, dynamic, dynamic> machine;
  List<Object> activeStateIdHistory = [];

  @override
  Future<void> notifyCreation() async {
    // print('Creation: ${machine.name} @ ${machine.activeStateId}');
    _addActiveState();
  }

  @override
  Future<void> notifyStateChange() async {
    // print('State change: ${machine.name} @ ${machine.activeStateId}');
    _addActiveState();
  }

  void _addActiveState() {
    // activeStateIdHistory.add('${machine.name}@${machine.activeStateId}');
    activeStateIdHistory.add(machine.getActiveStateRecursive());
    // activeStateIdHistory
    //     .add(machine.getStructureRecursive(includeInactive: false).toString());
  }
}

class SyncMonitor extends TestMonitor {
  SyncMonitor(Machine<dynamic, dynamic, dynamic> m) : super(m);

  @override
  Future<void> notifyCreation() async {
    await super.notifyCreation();
  }

  @override
  Future<void> notifyStateChange() async {
    await super.notifyStateChange();
  }
}

class AsyncMonitor extends TestMonitor {
  AsyncMonitor(Machine<dynamic, dynamic, dynamic> m) : super(m);

  @override
  Future<void> notifyCreation() async {
    await super.notifyCreation();
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> notifyStateChange() async {
    await super.notifyStateChange();
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}

enum S { a, b, c }

enum E { forward, self }

enum T { toA, toB, toC }

Machine<S, E, T> createMachine({
  bool root = true,
  List<Monitor Function(Machine<dynamic, dynamic, dynamic> m)>? monitorCreators,
}) =>
    Machine<S, E, T>(
      name: root ? 'root' : 'child',
      initialStateId: S.a,
      monitorCreators: monitorCreators,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
            E.self: [T.toA],
          },
          onEntry: Action(
            description: 'onEntry fwd',
            action: (machine, arg) async {
              // print('${machine.name}@A: onEntry fire');
              await machine.fire(E.forward);
            },
          ),
          onExit: Action(
            description: 'onExit fwd',
            action: (machine, arg) async {
              // print('${machine.name}@A: onExit fire');
              // await machine.fire(E.self);
            },
          ),
        ),
        S.b: State(
          etm: {
            E.forward: [T.toC],
          },
          onEntry: Action(
            description: 'onEntry fwd',
            action: (machine, arg) async {
              // print('${machine.name}@B: onEntry fire');
              await machine.fire(E.forward);
            },
          ),
          regions: [
            if (root) Region<S, E, T, S>(machine: createMachine(root: false))
          ],
        ),
        S.c: State(),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
        T.toC: Transition(to: S.c),
      },
    );
