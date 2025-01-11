import 'package:hisma/hisma.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void main() async {
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    // (machine) => ActiveStateMonitor(machine),
  ];
  await sm.start();
  // sm;
}

enum MA {
  m1,
  sm1,
  ssm1,
}

enum S {
  s1,
  s2,
}

enum E {
  e1,
  e2,
}

enum T {
  t1,
  t2,
  t3,
}

enum EN {
  e1,
  e2,
}

enum EX {
  e1,
  e2,
}

enum M {
  m1,
  m2,
}

//------------------------

enum SS {
  ss1,
  ss2,
  exit1,
}

enum SE {
  sea,
  se1,
  se2,
  sed,
}

enum ST {
  t1,
  t2,
}

enum SEN {
  e1,
  e2,
}

enum SEX {
  e1,
  e2,
}

enum SM {
  m1,
  m2,
}

//------------------------

enum SSS {
  en1,
  sss1,
  sss2,
  ex1,
}

enum SSE {
  ssea,
  sse1,
  sse2,
  ssed,
}

enum SST {
  t1,
  t2,
}

enum SSEN {
  e1,
  t2,
}

//------------------------

final sm = Machine<S, E, T>(
  events: E.values,
  name: 'm1',
  initialStateId: S.s1,
  transitions: {
    T.t1: Transition(to: S.s2),
    T.t3: Transition(
      to: S.s2,
      guard: Guard(
        description: 'always',
        condition: (machine, data) async => true,
      ),
      priority: 1,
    ),
    T.t2: Transition(to: S.s1),
  },
  states: {
    S.s1: State(
      etm: {
        E.e1: [T.t1],
      },
    ),
    S.s2: State(
      etm: {
        E.e2: [T.t2],
      },
      regions: [
        Region(
          machine: Machine<SS, SE, ST>(
            events: SE.values,
            name: 'sm1',
            initialStateId: SS.ss2,
            transitions: {
              ST.t1: Transition(to: SS.ss2),
              ST.t2: Transition(to: SS.ss1),
            },
            states: {
              SS.ss1: State(
                etm: {
                  SE.se1: [ST.t1],
                },
              ),
              SS.ss2: State(
                etm: {
                  SE.se2: [ST.t2],
                },
                regions: [
                  Region<SS, SE, ST, SSS>(
                    machine: Machine<SSS, SSE, SST>(
                      events: SSE.values,
                      name: 'ssm1',
                      initialStateId: SSS.sss2,
                      transitions: {
                        SST.t1: Transition(to: SSS.sss2),
                        SST.t2: Transition(to: SSS.sss1),
                      },
                      states: {
                        SSS.sss1: State(
                          etm: {
                            SSE.sse1: [SST.t1],
                          },
                        ),
                        SSS.sss2: State(
                          etm: {
                            SSE.sse2: [SST.t2],
                          },
                        ),
                        SSS.en1: EntryPoint([SST.t2]),
                      },
                    ),
                    entryConnectors: {
                      Trigger(source: SS.ss1, event: SE.se1, transition: ST.t1):
                          SSS.en1,
                    },
                    exitConnectors: {},
                  ),
                ],
              ),
            },
          ),
          entryConnectors: {
            Trigger(source: S.s1, event: E.e1, transition: T.t3): SEN.e1,
          },
          exitConnectors: {
            SEX.e1: E.e2,
          },
        ),
      ],
    ),
  },
);
