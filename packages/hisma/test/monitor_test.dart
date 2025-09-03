// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:test/scaffolding.dart';

abstract class TestMonitor implements Monitor {
  TestMonitor(this.machine);
  Machine<dynamic, dynamic, dynamic> machine;
  List<String> activeStateIdHistory = [];

  @override
  Future<void> notifyCreation() async {
    print('Creation: ${machine.name} @ ${machine.activeStateId}');
    _addActiveState();
  }

  @override
  Future<void> notifyStateChange() async {
    print('State change: ${machine.name} @ ${machine.activeStateId}');
    _addActiveState();
  }

  void _addActiveState() {
    // activeStateIdHistory.add('${machine.name}@${machine.activeStateId}');
    activeStateIdHistory
        .add(machine.getStructureRecursive(includeInactive: false).toString());
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
              print('${machine.name}@A: onEntry fire');
              await machine.fire(E.forward);
            },
          ),
          onExit: Action(
            description: 'onExit fwd',
            action: (machine, arg) async {
              print('${machine.name}@A: onExit fire');
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
              print('${machine.name}@B: onEntry fire');
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

void main() {
  test(
    'machine monitoring test',
    () async {
      late TestMonitor monitor;
      Machine.monitorCreators = [
        // (m) => ConsoleMonitor(m),
        // (m) => VisualMonitor(m),
      ];
      final m = createMachine(
        monitorCreators: [
          (m) {
            return monitor = SyncMonitor(m);
          }
        ],
      );
      print(monitor.activeStateIdHistory);
      await m.start();
      // await Future<void>.delayed(Duration.zero);
      print(monitor.activeStateIdHistory);
    },
  );
}
