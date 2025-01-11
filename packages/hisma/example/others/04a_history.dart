// ignore_for_file: avoid_print, file_names

import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void main(List<String> args) {
  initLogging();
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];

  sm.start();
}

enum S { on, off }

enum E { on, off }

enum T { toOn, toOff }

final sm = Machine<S, E, T>(
  name: 'l1',
  events: E.values,
  initialStateId: S.off,
  states: {
    S.off: State(
      etm: {
        E.on: [T.toOn],
      },
    ),
    S.on: State(
      etm: {
        E.off: [T.toOff],
      },
      regions: [
        Region(
          machine: Machine<S, E, T>(
            history: HistoryLevel.deep,
            name: 'l2',
            events: E.values,
            initialStateId: S.off,
            states: {
              S.off: State(
                etm: {
                  E.on: [T.toOn],
                },
              ),
              S.on: State(
                etm: {
                  E.off: [T.toOff],
                },
                regions: [
                  Region(
                    machine: Machine<S, E, T>(
                      name: 'l3',
                      events: E.values,
                      initialStateId: S.off,
                      states: {
                        S.off: State(
                          etm: {
                            E.on: [T.toOn],
                          },
                        ),
                        S.on: State(
                          etm: {
                            E.off: [T.toOff],
                          },
                          regions: [
                            Region(
                              machine: Machine<S, E, T>(
                                name: 'l4',
                                events: E.values,
                                initialStateId: S.off,
                                states: {
                                  S.off: State(
                                    etm: {
                                      E.on: [T.toOn],
                                    },
                                  ),
                                  S.on: State(
                                    etm: {
                                      E.off: [T.toOff],
                                    },
                                  ),
                                },
                                transitions: {
                                  T.toOn: Transition(to: S.on),
                                  T.toOff: Transition(to: S.off),
                                },
                              ),
                            ),
                          ],
                        ),
                      },
                      transitions: {
                        T.toOn: Transition(to: S.on),
                        T.toOff: Transition(to: S.off),
                      },
                    ),
                  ),
                ],
              ),
            },
            transitions: {
              T.toOn: Transition(to: S.on),
              T.toOff: Transition(to: S.off),
            },
          ),
        ),
      ],
    ),
  },
  transitions: {
    T.toOn: Transition(to: S.on),
    T.toOff: Transition(to: S.off),
  },
);
