// ignore_for_file: unused_local_variable, avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

//------------------------------------------------------------------------------

enum S0 { shallow, deep, en3, a, b, c }

enum E0 { forward, back, shallow, deep }

enum T0 { a, b, c }

final cState = State<E0, T0, S0>(
  etm: {
    E0.forward: [T0.a],
    E0.back: [T0.b],
  },
);

final template = StateMachine<S0, E0, T0>(
  events: E0.values,
  name: 'template',
  initialStateId: S0.a,
  // history: HistoryLevel.shallow,
  states: {
    S0.shallow: HistoryEntryPoint(HistoryLevel.shallow),
    S0.deep: HistoryEntryPoint(HistoryLevel.deep),
    // S0.en3: EntryPoint(S0.b),
    S0.a: State(
      etm: {
        E0.forward: [T0.b],
        E0.back: [T0.c],
      },
    ),
    S0.b: State(
      etm: {
        E0.shallow: [T0.c],
        E0.deep: [T0.c],
        E0.back: [T0.a],
      },
    ),
    S0.c: cState,
  },
  transitions: {
    T0.a: Transition(to: S0.a),
    T0.b: Transition(to: S0.b),
    T0.c: Transition(to: S0.c),
  },
);

Future<void> main(List<String> args) async {
  initLogging();

  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];
//------------------------------------------------------------------------------

  // final al3a1a = template.copyWith(name: 'al3a1a');
  // final al3a1b = template.copyWith(name: 'al3a1b');
  // final al3a2a = template.copyWith(name: 'al3a2a');
  // final al3a2b = template.copyWith(name: 'al3a2b');

  final al3b1a = template.copyWith(name: 'al3b1a');
  final al3b1b = template.copyWith(name: 'al3b1b');
  final al3b2a = template.copyWith(name: 'al3b2a');
  // final al3b2b = template.copyWith(name: 'al3b2b');
//------------------------------------------------------------------------------
/*

  final l2a1 = template.copyWith(
    name: 'l2a1',
    // states: (template.states[S0.c] as State).regions,
    states: StateMap<S0, E0, T0>.from(template.states)
      ..[S0.c] = State(
        etm: {
          E0.forward: [T0.a],
          E0.back: [T0.b],
        },
        regions: [
          Region(machine: l3a1a),
          Region(machine: l3a1b),
        ],
      ),
  );

  // (l2a1.states[S0.c] as State).regions = [];

  final l2a2 = template.copyWith(name: 'l2a2');

  final l2b1 = template.copyWith(name: 'l2b1');
  final l2b2 = template.copyWith(name: 'l2b2');

//------------------------------------------------------------------------------

  final l1a = template.copyWith(name: 'l1a')
    ..states.remove(S0.c)
    ..states[S0.c] = State(
      etm: {
        E0.forward: [T0.a],
        E0.back: [T0.b],
      },
      regions: [
        Region(machine: l2a1),
        Region(machine: l2a2),
      ],
    )
    ..setIt();

  final l1b = template.copyWith(name: 'l1b')
    ..states[S0.c] = State(
      etm: {
        E0.forward: [T0.a],
        E0.back: [T0.b],
      },
      // regions: [
      //   Region(machine: l2b1),
      //   Region(machine: l2b2),
      // ],
    )
    ..setIt();

//------------------------------------------------------------------------------
  final l0 = template.copyWith(
    name: 'l0',
  )
    ..states.remove(S0.c)
    ..states[S0.c] = State(
      etm: {
        E0.forward: [T0.a],
        E0.back: [T0.b],
      },
      regions: [
        Region(machine: l1b),
      ],
    )
    ..setIt();
*/
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

  print('Start.');
  // template.setIt();
  // l0.setIt();
  // l1a.setIt();
  // l1b.setIt();
  // l2a1.setIt();
  // l2a2.setIt();
  // l2b1.setIt();
  // l2b2.setIt();
  // l3a1a.setIt();
  // l3a1b.setIt();

  // template.setIt();
  final heh = template.copyWith(
    name: 'heh',
    states: template.states.map((stateId, state) {
      if (stateId == S0.c) {
        final s = state as State<E0, T0, S0>;
        return MapEntry(
          stateId,
          s.copyWith(regions: [Region(machine: al3b1a)]),
        );
      } else {
        return MapEntry(stateId, state);
      }
    }),
  )..start();

  final heh2 = template.copyWith(
    name: 'heh2',
    states: template.states.map(
      (stateId, state) => MapEntry(
        stateId,
        stateId == S0.c
            ? (state as State<E0, T0, S0>)
                .copyWith(regions: [Region(machine: al3b1b)])
            : state,
      ),
    ),
  )..start();

  final heh3 = template.copyWith(
    name: 'heh3',
    states: {
      ...template.states,
      S0.c: (template.states[S0.c]! as State<E0, T0, S0>)
          .copyWith(regions: [Region(machine: al3b2a)]),
    },
  )..start();

  StateMachine<S0, E0, T0> getMachine({
    required String name,
    List<StateMachine<S0, E0, T0>> machines = const [],
    HistoryLevel? history,
  }) {
    return template.copyWith(
      name: name,
      history: history,
      states: {
        ...template.states,
        S0.c: (template.states[S0.c]! as State<E0, T0, S0>).copyWith(
          regions: machines
              .map(
                (machine) => Region<S0, E0, T0, S0>(
                  machine: machine,
                  entryConnectors: {
                    Trigger(
                      event: E0.shallow,
                      source: S0.b,
                      transition: T0.c,
                    ): S0.shallow,
                    Trigger(
                      event: E0.deep,
                      source: S0.b,
                      transition: T0.c,
                    ): S0.deep
                  },
                ),
              )
              .toList(),
        ),
      },
    );
  }
/*
  final l0 = getMachine(
    name: 'l0',
    machines: [
      getMachine(
        name: 'l1a',
        machines: [
          getMachine(
            name: 'l2a1',
            machines: [
              getMachine(
                name: 'l3a1a',
                machines: [],
              ),
              getMachine(
                name: 'l3a1b',
                machines: [],
              ),
            ],
          ),
          getMachine(
            name: 'l2a2',
            machines: [
              getMachine(
                name: 'l3a2a',
                machines: [],
              ),
              getMachine(
                name: 'l3a2b',
                machines: [],
              ),
            ],
          ),
        ],
      ),
      getMachine(
        name: 'l1b',
        machines: [
          getMachine(
            name: 'l2b1',
            machines: [
              getMachine(
                name: 'l3b1a',
              ),
              getMachine(
                name: 'l3b1b',
              ),
            ],
          ),
          getMachine(
            name: 'l2b2',
            machines: [
              getMachine(
                name: 'l3b2a',
              ),
              getMachine(
                name: 'l3b2b',
              ),
            ],
          ),
        ],
      ),
    ],
  )..start();
*/

  /*final l0 = getMachine(
    name: 'l0',
    machines: [
      getMachine(
        name: 'l1a',
        // history: HistoryLevel.deep,
        machines: [
          getMachine(
            name: 'l2a1',
            machines: [
              getMachine(
                name: 'l3a1a',
                machines: [
                  getMachine(
                    name: 'l4a1a',
                    machines: [
                      getMachine(
                        name: 'l5a1a',
                        machines: [
                          getMachine(
                            name: 'l6a1a',
                            machines: [
                              getMachine(
                                name: 'l7a1a',
                                machines: [
                                  getMachine(
                                    name: 'l8a1a',
                                    machines: [
                                      getMachine(
                                        name: 'l9a1a',
                                        machines: [
                                          getMachine(
                                            name: 'l10a1a',
                                            machines: [
                                              getMachine(
                                                name: 'l11a1a',
                                                machines: [
                                                  getMachine(
                                                    name: 'l12a1a',
                                                    machines: [
                                                      getMachine(
                                                        name: 'l13a1a',
                                                        machines: [],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      getMachine(
                        name: 'l5a1b',
                        machines: [],
                      ),
                    ],
                  ),
                  getMachine(
                    name: 'l4a1b',
                    machines: [
                      getMachine(
                        name: 'l5b1a',
                        machines: [],
                      ),
                      getMachine(
                        name: 'l5b1b',
                        machines: [],
                      ),
                    ],
                  ),
                ],
              ),
              getMachine(
                name: 'l3a1b',
                machines: [],
              ),
            ],
          ),
          getMachine(
            name: 'l2a2',
            machines: [
              getMachine(
                name: 'l3a2a',
                machines: [],
              ),
              getMachine(
                name: 'l3a2b',
                machines: [],
              ),
            ],
          ),
        ],
      ),
      getMachine(
        name: 'l1b',
        machines: [
          getMachine(
            name: 'l2b1',
            machines: [
              getMachine(
                name: 'l3b1a',
              ),
              getMachine(
                name: 'l3b1b',
              ),
            ],
          ),
          getMachine(
            name: 'l2b2',
            machines: [
              getMachine(
                name: 'l3b2a',
              ),
              getMachine(
                name: 'l3b2b',
              ),
            ],
          ),
        ],
      ),
    ],
  )..start();*/

  final l0 = getMachine(
    name: 'l0',
    machines: [
      getMachine(
        name: 'l1a',
        // history: HistoryLevel.deep,
        machines: [
          getMachine(
            name: 'l2a1',
            machines: [
              getMachine(
                name: 'l3a1a',
                machines: [
                  getMachine(
                    name: 'l3a1a1',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l3a1b2',
                    machines: [],
                  ),
                ],
              ),
              getMachine(
                name: 'l3a1b',
                machines: [
                  getMachine(
                    name: 'l3a1a3',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l3a1b4',
                    machines: [],
                  ),
                ],
              ),
            ],
          ),
          getMachine(
            name: 'l2a2',
            machines: [
              getMachine(
                name: 'l3a2a',
                machines: [
                  getMachine(
                    name: 'l3a2a1',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l3a2b2',
                    machines: [],
                  ),
                ],
              ),
              getMachine(
                name: 'l3a2b',
                machines: [
                  getMachine(
                    name: 'l3a2a3',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l3a2b4',
                    machines: [],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      getMachine(
        name: 'l1b',
        machines: [
          getMachine(
            name: 'l2b1',
            machines: [
              getMachine(
                name: 'l3b1a',
                machines: [
                  getMachine(
                    name: 'l4b1a1',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l4b1b2',
                    machines: [],
                  ),
                ],
              ),
              getMachine(
                name: 'l3b1b',
                machines: [
                  getMachine(
                    name: 'l4b1a3',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l4b1b4',
                    machines: [],
                  ),
                ],
              ),
            ],
          ),
          getMachine(
            name: 'l2b2',
            machines: [
              getMachine(
                name: 'l3b2a',
                machines: [
                  getMachine(
                    name: 'l4b2a1',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l4b2b2',
                    machines: [],
                  ),
                ],
              ),
              getMachine(
                name: 'l3b2b',
                machines: [
                  getMachine(
                    name: 'l4b2a3',
                    machines: [],
                  ),
                  getMachine(
                    name: 'l4b2b4',
                    machines: [],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  )..start();

  // final heh4 = template.copyWith(
  //   name: 'heh3',
  //   states: {
  //     ...template.states,
  //     S0.c: cState.copyWith(regions: [Region(machine: l3b2b)]),
  //   },
  // )..start();

  // await template.start();
  // await l3a1a.start();
  // Future<void>.delayed(
  //   const Duration(days: 1),
  //   () => print('Completed.'),
  // );
  print('Done.');
}
