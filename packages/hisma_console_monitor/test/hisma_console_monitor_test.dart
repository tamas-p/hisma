// ignore_for_file: avoid_print, constant_identifier_names, non_constant_identifier_names

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:test/test.dart';

void main() {
  final buff = StringBuffer();

  group(
    'ConsoleMonitor tests',
    () {
      group('class level setting', () {
        test(
            'Test default ConsoleMonitor configuration (with includeInactive=true)',
            () async {
          Machine.monitorCreators = [
            (m) => ConsoleMonitor(
                  m,
                  // includeInactive: false,
                  printer: (output) => buff.write(output),
                ),
          ];

          late Machine<S, E, T> m;
          m = getMachine();
          await runTest(
            buff,
            m,
            Stage(
              created: _created,
              started: _started,
              l0_fire: _l0_fire,
              l0l1a_fire: _l0l1a_fire,
              l0l1al2a_fire: _l0l1al2a_fire,
              l0l1al2al3a_fire: _l0l1al2al3a_fire,
            ),
          );
        });

        test('Test ConsoleMonitor configuration with includeInactive=false',
            () async {
          Machine.monitorCreators = [
            (m) => ConsoleMonitor(
                  m,
                  includeInactive: false,
                  printer: (output) => buff.write(output),
                ),
          ];

          late Machine<S, E, T> m;
          m = getMachine();

          await runTest(
            buff,
            m,
            Stage(
              created: _created_active,
              started: _started_active,
              l0_fire: _l0_fire_active,
              l0l1a_fire: _l0l1a_fire_active,
              l0l1al2a_fire: _l0l1al2a_fire_active,
              l0l1al2al3a_fire: _l0l1al2al3a_fire_active,
            ),
          );
        });
      });
    },
  );

  group('instance level setting', () {
    setUp(
      () {
        // Need to empty class level setting to be able to test
        // instance level setting.
        Machine.monitorCreators = [];
      },
    );

    group('Constructor configuration', () {
      test(
        'Test default ConsoleMonitor configuration (with includeInactive=true)',
        () async {
          final m = getMachineWithMonitor([
            (m) => ConsoleMonitor(
                  m,
                  // includeInactive: false,
                  printer: (output) => buff.write(output),
                ),
          ]);
          await runTest(
            buff,
            m,
            Stage(
              created: _created_instance,
              started: _started_instance,
              l0_fire: _l0_fire_instance,
              l0l1a_fire: _l0l1a_fire_instance,
              l0l1al2a_fire: _l0l1al2a_fire_instance,
              l0l1al2al3a_fire: _l0l1al2al3a_fire_instance,
            ),
          );
        },
      );

      test(
        'Test ConsoleMonitor configuration with includeInactive=false',
        () async {
          final m = getMachineWithMonitor([
            (m) => ConsoleMonitor(
                  m,
                  includeInactive: false,
                  printer: (output) => buff.write(output),
                ),
          ]);
          await runTest(
            buff,
            m,
            Stage(
              created: _created_active_instance,
              started: _started_active_instance,
              l0_fire: _l0_fire_active_instance,
              l0l1a_fire: _l0l1a_fire_active_instance,
              l0l1al2a_fire: _l0l1al2a_fire_active_instance,
              l0l1al2al3a_fire: _l0l1al2al3a_fire_active_instance,
            ),
          );
        },
      );
    });
    group('addMonitorCreators configuration', () {
      test(
        'Test default ConsoleMonitor configuration (with includeInactive=true)',
        () async {
          final m = getMachine();
          m.addMonitors([
            (m) => ConsoleMonitor(
                  m,
                  // includeInactive: false,
                  printer: (output) => buff.write(output),
                ),
          ]);

          await runTest(
            buff,
            m,
            Stage(
              created: _created_instance,
              started: _started_instance,
              l0_fire: _l0_fire_instance,
              l0l1a_fire: _l0l1a_fire_instance,
              l0l1al2a_fire: _l0l1al2a_fire_instance,
              l0l1al2al3a_fire: _l0l1al2al3a_fire_instance,
            ),
          );
        },
      );

      test(
        'Test ConsoleMonitor configuration with includeInactive=false',
        () async {
          final m = getMachine();
          m.addMonitors([
            (m) => ConsoleMonitor(
                  m,
                  includeInactive: false,
                  printer: (output) => buff.write(output),
                ),
          ]);
          await runTest(
            buff,
            m,
            Stage(
              created: _created_active_instance,
              started: _started_active_instance,
              l0_fire: _l0_fire_active_instance,
              l0l1a_fire: _l0l1a_fire_active_instance,
              l0l1al2a_fire: _l0l1al2a_fire_active_instance,
              l0l1al2al3a_fire: _l0l1al2al3a_fire_active_instance,
            ),
          );
        },
      );
    });
  });
}

class Stage {
  Stage({
    required this.created,
    required this.started,
    required this.l0_fire,
    required this.l0l1a_fire,
    required this.l0l1al2a_fire,
    required this.l0l1al2al3a_fire,
  });
  String created;
  String started;
  String l0_fire;
  String l0l1a_fire;
  String l0l1al2a_fire;
  String l0l1al2al3a_fire;
}

Future<void> runTest(StringBuffer buff, Machine<S, E, T> m, Stage stage) async {
  expect(buff.takeString(), equals(stage.created));

  await m.start();
  expect(buff.takeString(), equals(stage.started));

  await m.fire(E.forward);
  expect(buff.takeString(), equals(stage.l0_fire));

  await m.find<S, E, T>('l0.l1a').fire(E.forward);
  expect(buff.takeString(), equals(stage.l0l1a_fire));

  await m.find<S, E, T>('l0.l1a.l2a').fire(E.forward);
  expect(buff.takeString(), equals(stage.l0l1al2a_fire));

  await m.find<S, E, T>('l0.l1a.l2a.l3a').fire(E.forward);
  expect(buff.takeString(), equals(stage.l0l1al2al3a_fire));
}

enum S { a, b }

enum E { forward }

enum T { toA, toB }

String cn(String? name, int level, String id) =>
    '${name == null ? '' : '$name.'}l$level$id';

Machine<S, E, T> getMachineWithMonitor(
  List<Monitor Function(Machine<dynamic, dynamic, dynamic>)> monitorCreators,
) =>
    getMachine(0, null, '', monitorCreators);

Machine<S, E, T> getMachine([
  int l = 0,
  String? parent,
  String id = '',
  // ignore: avoid_positional_boolean_parameters
  List<Monitor Function(Machine<dynamic, dynamic, dynamic>)>? monitorCreators,
]) =>
    Machine(
      monitorCreators:
          monitorCreators != null && l == 0 ? monitorCreators : null,
      name: cn(parent, l, id),
      initialStateId: S.a,
      states: {
        S.a: State(
          etm: {
            E.forward: [T.toB],
          },
        ),
        S.b: State(
          etm: {
            E.forward: [T.toA],
          },
          regions: [
            if (l < 3)
              Region<S, E, T, S>(
                machine: getMachine(l + 1, cn(parent, l, id), 'a'),
              ),
            if (l < 3)
              Region<S, E, T, S>(
                machine: getMachine(l + 1, cn(parent, l, id), 'b'),
              ),
          ],
        ),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
      },
    );

extension StringBufferExtension on StringBuffer {
  String takeString() {
    final result = toString();
    clear();
    return result;
  }
}

const _created = '''
Machine l0.l1a.l2a.l3a monitoring> created:
(l0.l1a.l2a.l3a)
    ├─S.a
    └─S.b
Machine l0.l1a.l2a.l3b monitoring> created:
(l0.l1a.l2a.l3b)
    ├─S.a
    └─S.b
Machine l0.l1a.l2a monitoring> created:
(l0.l1a.l2a)
    ├─S.a
    └─S.b
        ├─(l0.l1a.l2a.l3a)
        │   ├─S.a
        │   └─S.b
        └─(l0.l1a.l2a.l3b)
            ├─S.a
            └─S.b
Machine l0.l1a.l2b.l3a monitoring> created:
(l0.l1a.l2b.l3a)
    ├─S.a
    └─S.b
Machine l0.l1a.l2b.l3b monitoring> created:
(l0.l1a.l2b.l3b)
    ├─S.a
    └─S.b
Machine l0.l1a.l2b monitoring> created:
(l0.l1a.l2b)
    ├─S.a
    └─S.b
        ├─(l0.l1a.l2b.l3a)
        │   ├─S.a
        │   └─S.b
        └─(l0.l1a.l2b.l3b)
            ├─S.a
            └─S.b
Machine l0.l1a monitoring> created:
(l0.l1a)
    ├─S.a
    └─S.b
        ├─(l0.l1a.l2a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1a.l2a.l3a)
        │       │   ├─S.a
        │       │   └─S.b
        │       └─(l0.l1a.l2a.l3b)
        │           ├─S.a
        │           └─S.b
        └─(l0.l1a.l2b)
            ├─S.a
            └─S.b
                ├─(l0.l1a.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1a.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0.l1b.l2a.l3a monitoring> created:
(l0.l1b.l2a.l3a)
    ├─S.a
    └─S.b
Machine l0.l1b.l2a.l3b monitoring> created:
(l0.l1b.l2a.l3b)
    ├─S.a
    └─S.b
Machine l0.l1b.l2a monitoring> created:
(l0.l1b.l2a)
    ├─S.a
    └─S.b
        ├─(l0.l1b.l2a.l3a)
        │   ├─S.a
        │   └─S.b
        └─(l0.l1b.l2a.l3b)
            ├─S.a
            └─S.b
Machine l0.l1b.l2b.l3a monitoring> created:
(l0.l1b.l2b.l3a)
    ├─S.a
    └─S.b
Machine l0.l1b.l2b.l3b monitoring> created:
(l0.l1b.l2b.l3b)
    ├─S.a
    └─S.b
Machine l0.l1b.l2b monitoring> created:
(l0.l1b.l2b)
    ├─S.a
    └─S.b
        ├─(l0.l1b.l2b.l3a)
        │   ├─S.a
        │   └─S.b
        └─(l0.l1b.l2b.l3b)
            ├─S.a
            └─S.b
Machine l0.l1b monitoring> created:
(l0.l1b)
    ├─S.a
    └─S.b
        ├─(l0.l1b.l2a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1b.l2a.l3a)
        │       │   ├─S.a
        │       │   └─S.b
        │       └─(l0.l1b.l2a.l3b)
        │           ├─S.a
        │           └─S.b
        └─(l0.l1b.l2b)
            ├─S.a
            └─S.b
                ├─(l0.l1b.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1b.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0 monitoring> created:
(l0)
    ├─S.a
    └─S.b
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _started = '''
Machine l0 monitoring> state changed:
(l0)
    ├─S.a (*)
    └─S.b
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0_fire = '''
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    ├─S.a (*)
    └─S.b
        ├─(l0.l1a.l2a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1a.l2a.l3a)
        │       │   ├─S.a
        │       │   └─S.b
        │       └─(l0.l1a.l2a.l3b)
        │           ├─S.a
        │           └─S.b
        └─(l0.l1a.l2b)
            ├─S.a
            └─S.b
                ├─(l0.l1a.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1a.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0.l1b monitoring> state changed:
(l0.l1b)
    ├─S.a (*)
    └─S.b
        ├─(l0.l1b.l2a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1b.l2a.l3a)
        │       │   ├─S.a
        │       │   └─S.b
        │       └─(l0.l1b.l2a.l3b)
        │           ├─S.a
        │           └─S.b
        └─(l0.l1b.l2b)
            ├─S.a
            └─S.b
                ├─(l0.l1b.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1b.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a (*)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0l1a_fire = '''
Machine l0.l1a.l2a monitoring> state changed:
(l0.l1a.l2a)
    ├─S.a (*)
    └─S.b
        ├─(l0.l1a.l2a.l3a)
        │   ├─S.a
        │   └─S.b
        └─(l0.l1a.l2a.l3b)
            ├─S.a
            └─S.b
Machine l0.l1a.l2b monitoring> state changed:
(l0.l1a.l2b)
    ├─S.a (*)
    └─S.b
        ├─(l0.l1a.l2b.l3a)
        │   ├─S.a
        │   └─S.b
        └─(l0.l1a.l2b.l3b)
            ├─S.a
            └─S.b
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a.l2a)
        │   ├─S.a (*)
        │   └─S.b
        │       ├─(l0.l1a.l2a.l3a)
        │       │   ├─S.a
        │       │   └─S.b
        │       └─(l0.l1a.l2a.l3b)
        │           ├─S.a
        │           └─S.b
        └─(l0.l1a.l2b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1a.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1a.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a (*)
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a (*)
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0l1al2a_fire = '''
Machine l0.l1a.l2a.l3a monitoring> state changed:
(l0.l1a.l2a.l3a)
    ├─S.a (*)
    └─S.b
Machine l0.l1a.l2a.l3b monitoring> state changed:
(l0.l1a.l2a.l3b)
    ├─S.a (*)
    └─S.b
Machine l0.l1a.l2a monitoring> state changed:
(l0.l1a.l2a)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a.l2a.l3a)
        │   ├─S.a (*)
        │   └─S.b
        └─(l0.l1a.l2a.l3b)
            ├─S.a (*)
            └─S.b
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a.l2a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a.l3a)
        │       │   ├─S.a (*)
        │       │   └─S.b
        │       └─(l0.l1a.l2a.l3b)
        │           ├─S.a (*)
        │           └─S.b
        └─(l0.l1a.l2b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1a.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1a.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b (*)
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a (*)
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a (*)
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a (*)
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0l1al2al3a_fire = '''
Machine l0.l1a.l2a.l3a monitoring> state changed:
(l0.l1a.l2a.l3a)
    ├─S.a
    └─S.b (*)
Machine l0.l1a.l2a monitoring> state changed:
(l0.l1a.l2a)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a.l2a.l3a)
        │   ├─S.a
        │   └─S.b (*)
        └─(l0.l1a.l2a.l3b)
            ├─S.a (*)
            └─S.b
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a.l2a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a.l3a)
        │       │   ├─S.a
        │       │   └─S.b (*)
        │       └─(l0.l1a.l2a.l3b)
        │           ├─S.a (*)
        │           └─S.b
        └─(l0.l1a.l2b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1a.l2b.l3a)
                │   ├─S.a
                │   └─S.b
                └─(l0.l1a.l2b.l3b)
                    ├─S.a
                    └─S.b
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b (*)
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b (*)
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a (*)
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a (*)
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _created_active = '''
Machine l0.l1a.l2a.l3a monitoring> created:
Machine l0.l1a.l2a.l3b monitoring> created:
Machine l0.l1a.l2a monitoring> created:
Machine l0.l1a.l2b.l3a monitoring> created:
Machine l0.l1a.l2b.l3b monitoring> created:
Machine l0.l1a.l2b monitoring> created:
Machine l0.l1a monitoring> created:
Machine l0.l1b.l2a.l3a monitoring> created:
Machine l0.l1b.l2a.l3b monitoring> created:
Machine l0.l1b.l2a monitoring> created:
Machine l0.l1b.l2b.l3a monitoring> created:
Machine l0.l1b.l2b.l3b monitoring> created:
Machine l0.l1b.l2b monitoring> created:
Machine l0.l1b monitoring> created:
Machine l0 monitoring> created:
''';

const _started_active = '''
Machine l0 monitoring> state changed:
(l0)
    └─S.a
''';

const _l0_fire_active = '''
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    └─S.a
Machine l0.l1b monitoring> state changed:
(l0.l1b)
    └─S.a
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _l0l1a_fire_active = '''
Machine l0.l1a.l2a monitoring> state changed:
(l0.l1a.l2a)
    └─S.a
Machine l0.l1a.l2b monitoring> state changed:
(l0.l1a.l2b)
    └─S.a
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    └─S.b
        ├─(l0.l1a.l2a)
        │   └─S.a
        └─(l0.l1a.l2b)
            └─S.a
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   └─S.a
        │       └─(l0.l1a.l2b)
        │           └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _l0l1al2a_fire_active = '''
Machine l0.l1a.l2a.l3a monitoring> state changed:
(l0.l1a.l2a.l3a)
    └─S.a
Machine l0.l1a.l2a.l3b monitoring> state changed:
(l0.l1a.l2a.l3b)
    └─S.a
Machine l0.l1a.l2a monitoring> state changed:
(l0.l1a.l2a)
    └─S.b
        ├─(l0.l1a.l2a.l3a)
        │   └─S.a
        └─(l0.l1a.l2a.l3b)
            └─S.a
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    └─S.b
        ├─(l0.l1a.l2a)
        │   └─S.b
        │       ├─(l0.l1a.l2a.l3a)
        │       │   └─S.a
        │       └─(l0.l1a.l2a.l3b)
        │           └─S.a
        └─(l0.l1a.l2b)
            └─S.a
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   └─S.a
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           └─S.a
        │       └─(l0.l1a.l2b)
        │           └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _l0l1al2al3a_fire_active = '''
Machine l0.l1a.l2a.l3a monitoring> state changed:
(l0.l1a.l2a.l3a)
    └─S.b
Machine l0.l1a.l2a monitoring> state changed:
(l0.l1a.l2a)
    └─S.b
        ├─(l0.l1a.l2a.l3a)
        │   └─S.b
        └─(l0.l1a.l2a.l3b)
            └─S.a
Machine l0.l1a monitoring> state changed:
(l0.l1a)
    └─S.b
        ├─(l0.l1a.l2a)
        │   └─S.b
        │       ├─(l0.l1a.l2a.l3a)
        │       │   └─S.b
        │       └─(l0.l1a.l2a.l3b)
        │           └─S.a
        └─(l0.l1a.l2b)
            └─S.a
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           └─S.a
        │       └─(l0.l1a.l2b)
        │           └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _created_instance = '''
Machine l0 monitoring> created:
(l0)
    ├─S.a
    └─S.b
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _started_instance = '''
Machine l0 monitoring> state changed:
(l0)
    ├─S.a (*)
    └─S.b
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0_fire_instance = '''
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a (*)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0l1a_fire_instance = '''
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a (*)
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a (*)
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0l1al2a_fire_instance = '''
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b (*)
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a (*)
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a (*)
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a (*)
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _l0l1al2al3a_fire_instance = '''
Machine l0 monitoring> state changed:
(l0)
    ├─S.a
    └─S.b (*)
        ├─(l0.l1a)
        │   ├─S.a
        │   └─S.b (*)
        │       ├─(l0.l1a.l2a)
        │       │   ├─S.a
        │       │   └─S.b (*)
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   ├─S.a
        │       │       │   └─S.b (*)
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           ├─S.a (*)
        │       │           └─S.b
        │       └─(l0.l1a.l2b)
        │           ├─S.a (*)
        │           └─S.b
        │               ├─(l0.l1a.l2b.l3a)
        │               │   ├─S.a
        │               │   └─S.b
        │               └─(l0.l1a.l2b.l3b)
        │                   ├─S.a
        │                   └─S.b
        └─(l0.l1b)
            ├─S.a (*)
            └─S.b
                ├─(l0.l1b.l2a)
                │   ├─S.a
                │   └─S.b
                │       ├─(l0.l1b.l2a.l3a)
                │       │   ├─S.a
                │       │   └─S.b
                │       └─(l0.l1b.l2a.l3b)
                │           ├─S.a
                │           └─S.b
                └─(l0.l1b.l2b)
                    ├─S.a
                    └─S.b
                        ├─(l0.l1b.l2b.l3a)
                        │   ├─S.a
                        │   └─S.b
                        └─(l0.l1b.l2b.l3b)
                            ├─S.a
                            └─S.b
''';

const _created_active_instance = '''
Machine l0 monitoring> created:
''';

const _started_active_instance = '''
Machine l0 monitoring> state changed:
(l0)
    └─S.a
''';

const _l0_fire_active_instance = '''
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _l0l1a_fire_active_instance = '''
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   └─S.a
        │       └─(l0.l1a.l2b)
        │           └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _l0l1al2a_fire_active_instance = '''
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   └─S.a
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           └─S.a
        │       └─(l0.l1a.l2b)
        │           └─S.a
        └─(l0.l1b)
            └─S.a
''';

const _l0l1al2al3a_fire_active_instance = '''
Machine l0 monitoring> state changed:
(l0)
    └─S.b
        ├─(l0.l1a)
        │   └─S.b
        │       ├─(l0.l1a.l2a)
        │       │   └─S.b
        │       │       ├─(l0.l1a.l2a.l3a)
        │       │       │   └─S.b
        │       │       └─(l0.l1a.l2a.l3b)
        │       │           └─S.a
        │       └─(l0.l1a.l2b)
        │           └─S.a
        └─(l0.l1b)
            └─S.a
''';
