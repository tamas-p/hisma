// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

//------------------------------------------------------------------------------

enum S { en1, s1, s2, s3, s4 }

enum E { e1, e2, e3, e4, e5, e6 }

enum T { t1, t2, t3, t4, t5, t6 }

final m1 = StateMachine<S, E, T>(
  events: E.values,
  name: 'm1 machine 机器 機械 기계 машина something &&% #^',
  initialStateId: S.s1,
  states: {
    S.en1: EntryPoint(S.s2),
    S.s1: State(
      etm: {
        E.e1: [T.t1],
        E.e6: [T.t6],
      },
      onEntry: Action(
        description: 'someEntry()',
        action: (_, __) async {},
      ),
      onExit: Action(
        description: 'leaving this state',
        action: (_, __) async {},
      ),
      regions: [
        Region<S, E, T, SS>(
          machine: m1s1,
          entryConnectors: {
            Trigger(source: S.s2, event: E.e2, transition: T.t2): SS.en1,
          },
          exitConnectors: {
            SS.ex1: E.e1,
          },
        ),
        Region<S, E, T, SS2>(machine: m1s2),
      ],
    ),
    S.s2: State(
      etm: {
        E.e2: [T.t2],
        E.e3: [T.t3],
      },
    ),
    S.s3: State(
      etm: {
        E.e4: [T.t4],
        E.e5: [T.t5],
      },
    ),
  },
  transitions: {
    T.t1: Transition(
      to: S.s2,
      guard: Guard(
        description: 'always',
        condition: () => true,
      ),
    ),
    T.t2: Transition(
      to: S.s1,
      guard: Guard(description: 'a < b', condition: () => true),
      // onAction: Action(
      //   description: 'do that',
      //   action: (state) {},
      // ),
    ),
    T.t3: Transition(
      to: S.s2,
      guard: Guard(
        description: 'only if empty',
        condition: () => true,
      ),
    ),
    T.t4: Transition(
      to: S.s3,
      guard: Guard(
        description: 'i == 10',
        condition: () {
          var i = 10;
          i++;
          i--;
          return i == 10;
        },
      ),
    ),
    T.t5: Transition(to: S.s1),
    T.t6: Transition(
      to: S.s3,
      priority: 12,
      guard: Guard(
        condition: () => true,
        description: 'just for test',
      ),
    ),
  },
);

//------------------------------------------------------------------------------

enum SS { en1, s1, s2, s3, ex1 }

enum SE { e1, e2, e3, e4, e5 }

enum ST { t1, t2, t3, t4, t5 }

final m1s1 = StateMachine<SS, SE, ST>(
  events: SE.values,
  name: 'm1s1',
  initialStateId: SS.s1,
  states: {
    SS.en1: EntryPoint(SS.s2),
    SS.s1: State(
      etm: {
        SE.e1: [ST.t3],
        SE.e4: [ST.t4],
      },
    ),
    SS.s2: State(
      etm: {
        SE.e2: [ST.t2],
        SE.e5: [ST.t5],
      },
      regions: [
        Region<SS, SE, ST, SSS0>(
          machine: m1s1s1,
          entryConnectors: {
            Trigger.entryPoint(source: SS.en1): SSS0.en1,
          },
          exitConnectors: {
            SSS0.ex1: SE.e5,
            SSS0.ex2: SE.e5,
          },
        ),
      ],
    ),
    SS.s3: State(
      etm: {
        SE.e3: [ST.t1],
      },
    ),
    SS.ex1: ExitPoint(),
  },
  transitions: {
    ST.t1: Transition(to: SS.s2, priority: 2),
    ST.t2: Transition(to: SS.s3, priority: 4),
    ST.t3: Transition(to: SS.s1),
    ST.t4: Transition(to: SS.s3),
    ST.t5: Transition(to: SS.ex1),
  },
);

//------------------------------------------------------------------------------

enum SS2 { s1, s2, s3 }

enum SE2 { e1, e2, e3, e4, e5, e6 }

enum ST2 { t1, t2, t3, t4, t5, t6 }

final m1s2 = StateMachine<SS2, SE2, ST2>(
  events: SE2.values,
  name: 'm1s2',
  initialStateId: SS2.s1,
  states: {
    SS2.s1: State(
      etm: {
        SE2.e1: [ST2.t3],
        SE2.e4: [ST2.t2],
      },
    ),
    SS2.s2: State(
      etm: {
        SE2.e2: [ST2.t4],
        SE2.e5: [ST2.t5],
      },
      regions: [
        Region<SS2, SE2, ST2, SSS1>(
          machine: m1s2s1,
          exitConnectors: {
            SSS1.ex1: SE2.e5,
          },
        ),
        Region<SS2, SE2, ST2, SSS2>(
          machine: m1s2s2,
          entryConnectors: {
            Trigger(source: SS2.s3, event: SE2.e3, transition: ST2.t1):
                SSS2.en1,
            Trigger(source: SS2.s3, event: SE2.e6, transition: ST2.t6):
                SSS2.en1,
          },
          exitConnectors: {
            SSS2.ex1: SE2.e5,
          },
        ),
        Region<SS2, SE2, ST2, SSS3>(
          machine: m1s2s3,
          entryConnectors: {
            Trigger(source: SS2.s3, event: SE2.e3, transition: ST2.t1): SSS3.en1
          },
          exitConnectors: {
            SSS3.ex1: SE2.e2,
            SSS3.ex2: SE2.e2,
          },
        ),
      ],
    ),
    SS2.s3: State(
      etm: {
        SE2.e3: [ST2.t1],
        SE2.e6: [ST2.t6],
      },
    ),
  },
  transitions: {
    ST2.t1: Transition(to: SS2.s2, priority: 2),
    ST2.t2: Transition(to: SS2.s3, priority: 4),
    ST2.t3: Transition(to: SS2.s1),
    ST2.t4: Transition(to: SS2.s3),
    ST2.t5: Transition(to: SS2.s1),
    ST2.t6: Transition(to: SS2.s2),
  },
);

//------------------------------------------------------------------------------

enum SSS0 { en1, s1, s2, s3, ex1, ex2 }

enum SSE0 { e1, e2, e3, e4 }

enum SST0 { t1, t2, t3, t4, t5, t6 }

final m1s1s1 = StateMachine<SSS0, SSE0, SST0>(
  events: SSE0.values,
  name: 'm1s1s1',
  initialStateId: SSS0.s3,
  states: {
    SSS0.en1: EntryPoint(SSS0.s1),
    SSS0.s1: State(
      etm: {
        SSE0.e1: [SST0.t1],
        SSE0.e4: [SST0.t2],
      },
    ),
    SSS0.s2: State(
      etm: {
        SSE0.e2: [SST0.t3],
        SSE0.e3: [SST0.t5],
      },
    ),
    SSS0.s3: State(
      etm: {
        SSE0.e3: [SST0.t4],
        SSE0.e4: [SST0.t6],
      },
    ),
    SSS0.ex1: ExitPoint(),
    SSS0.ex2: ExitPoint(),
  },
  transitions: {
    SST0.t1: Transition(to: SSS0.s2),
    SST0.t2: Transition(to: SSS0.s3),
    SST0.t3: Transition(to: SSS0.s1),
    SST0.t4: Transition(to: SSS0.s3),
    SST0.t5: Transition(to: SSS0.ex1),
    SST0.t6: Transition(to: SSS0.ex2),
  },
);

//------------------------------------------------------------------------------

enum SSS1 { en1, s1, s2, s3, ex1 }

enum SSE1 { e1, e2, e3, e4, e5 }

enum SST1 { t1, t2, t3, t4, t5 }

final m1s2s1 = StateMachine<SSS1, SSE1, SST1>(
  events: SSE1.values,
  name: 'm1s2s1',
  initialStateId: SSS1.s1,
  states: {
    SSS1.en1: EntryPoint(SSS1.s2),
    SSS1.s1: State(
      etm: {
        SSE1.e1: [SST1.t1],
        SSE1.e4: [SST1.t4],
      },
    ),
    SSS1.s2: State(
      etm: {
        SSE1.e2: [SST1.t2],
        SSE1.e5: [SST1.t5],
      },
    ),
    SSS1.s3: State(
      etm: {
        SSE1.e3: [SST1.t3],
      },
    ),
    SSS1.ex1: ExitPoint(),
  },
  transitions: {
    SST1.t1: Transition(to: SSS1.s2),
    SST1.t2: Transition(to: SSS1.s3),
    SST1.t3: Transition(to: SSS1.s1),
    SST1.t4: Transition(to: SSS1.s3),
    SST1.t5: Transition(to: SSS1.ex1),
  },
);

//------------------------------------------------------------------------------

enum SSS2 { en1, s1, s2, s3, ex1 }

enum SSE2 { e1, e2, e3, e4, e5 }

enum SST2 { t1, t2, t3, t4, t5 }

final m1s2s2 = StateMachine<SSS2, SSE2, SST2>(
  events: SSE2.values,
  name: 'm1s2s2',
  initialStateId: SSS2.s1,
  states: {
    SSS2.en1: EntryPoint(SSS2.s2),
    SSS2.s1: State(
      etm: {
        SSE2.e1: [SST2.t4],
        SSE2.e4: [SST2.t2],
      },
    ),
    SSS2.s2: State(
      etm: {
        SSE2.e2: [SST2.t1],
        SSE2.e5: [SST2.t5],
        SSE2.e4: [SST2.t4],
      },
    ),
    SSS2.s3: State(
      etm: {
        SSE2.e3: [SST2.t3],
        SSE2.e2: [SST2.t5],
      },
    ),
    SSS2.ex1: ExitPoint(),
  },
  transitions: {
    SST2.t1: Transition(to: SSS2.s2),
    SST2.t2: Transition(to: SSS2.s3),
    SST2.t3: Transition(to: SSS2.s1),
    SST2.t4: Transition(to: SSS2.s3),
    SST2.t5: Transition(to: SSS2.ex1),
  },
);

//------------------------------------------------------------------------------

enum SSS3 { en1, s1, s2, s3, ex1, ex2 }

enum SSE3 { e1, e2, e3, e4, e5 }

enum SST3 { t1, t2, t3, t4, t5, t6 }

final m1s2s3 = StateMachine<SSS3, SSE3, SST3>(
  events: SSE3.values,
  name: 'm1s2s3',
  initialStateId: SSS3.s1,
  states: {
    SSS3.en1: EntryPoint(SSS3.s3),
    SSS3.s1: State(
      etm: {
        SSE3.e1: [SST3.t2],
        SSE3.e4: [SST3.t3],
      },
    ),
    SSS3.s2: State(
      etm: {
        SSE3.e2: [SST3.t4],
        SSE3.e5: [SST3.t5, SST3.t6],
      },
    ),
    SSS3.s3: State(
      etm: {
        SSE3.e3: [SST3.t1],
      },
    ),
    SSS3.ex1: ExitPoint(),
    SSS3.ex2: ExitPoint(),
  },
  transitions: {
    SST3.t1: Transition(to: SSS3.s2),
    SST3.t2: Transition(to: SSS3.s3),
    SST3.t3: Transition(to: SSS3.s1),
    SST3.t4: Transition(to: SSS3.s3),
    SST3.t5: Transition(to: SSS3.ex1),
    SST3.t6: Transition(to: SSS3.ex2),
  },
);

//------------------------------------------------------------------------------

Future<void> main() async {
  VisualMonitor.hostname = 'tam we/\\// %#@&(as';
  VisualMonitor.domain = 'some/ ~!!%&thing';
  StateMachine.monitorCreators = [
    // (machine) => VisualMonitor(
    //       machine,
    //       showRegions: {
    //         S.s1.toString(),
    //         SS2.s2.toString(),
    //       },
    //     ),
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(
          machine,
          printer: (str) {
            print('-MONITOR----------------------------------------------');
            print(str);
          },
        ),
  ];

  print('Start.');
  // await sm1.register();
  // await sm1.register();
  // await sm1.register();
  // await subSubSm3.register();
  // await subSubSm2.register();
  // await subSubSm1.register();
  // await subSubSm0.register();
  // await subSm2.register();
  // await subSm1.register();
  // await subSm1.register();
  // await subSm1.register();
  // await subSm1.register();
  // await subSm1.register();
  // await subSm1.register();
  // await subSm1.register();

  // m1;

  // Just to create all objects.
  await Future<void>.delayed(const Duration(seconds: 1));
  await Future<void>.delayed(const Duration(seconds: 1));

  print('sm1.hashCode=${m1.hashCode}');
  print('sm1.runtimeType=${m1.runtimeType}');
  print('subSm1.runtimeType=${m1s1.runtimeType}');
  print('subSm2.runtimeType=${m1s2.runtimeType}');

  // await m1s1s1.start();

  await m1.start();

/*
  await m1.fire(E.e1);
  await m1.fire(E.e3);
  await m1.fire(E.e2);
  await m1.fire(E.e6);
  await m1.fire(E.e4);
  await m1.fire(E.e5);

  // print(pretty(sm1.getActiveStateRecursive()));

  await m1s1.fire(SE.e4);
  await Future<void>.delayed(const Duration(seconds: 1));
  // print(pretty(sm1.getActiveStateRecursive()));

  // print('SM: ${sm1.toString()}, ${sm1.hashCode}');
  // print(pretty(sm1.getActiveStateRecursive()));
  await m1s1.fire(SE.e3);

  await m1.fire(E.e1);

  await m1.fire(E.e2);

  // ssm1.fire(SE.e2);
  // ssm1.fire(SE.e3);

  await m1s1s1.fire(SSE0.e1);
  await m1s1s1.fire(SSE0.e3);

  await Future<void>.delayed(const Duration(seconds: 1));

  await m1.notifyMonitors();

  await m1.notifyMonitors();

  await m1.fire(E.e2);
  await m1s1s1.fire(SSE0.e1);
  await m1s1s1.fire(SSE0.e3);
  await m1.fire(E.e2);
  await m1.fire(E.e6);
  await m1.fire(E.e5);
  await m1s2.fire(SE2.e4);
  await m1s2.fire(SE2.e3); // It triggers two EntryPoint transactions!
  // await m1s2.fire(SE2.e6);

  await m1s2s2.fire(SSE2.e5);
  await Future<void>.delayed(const Duration(seconds: 1));
  print('#################################################################');
  print(pretty(m1.getActiveStateRecursive()));
  print('#################################################################');
  await m1.notifyMonitors();

  await m1.fire(E.e6);

  await Future<void>.delayed(const Duration(seconds: 1));

  print('main done.');
  print('SM: ${m1.toString()}, ${m1.hashCode}');
  print('Exit.');
  */
}
