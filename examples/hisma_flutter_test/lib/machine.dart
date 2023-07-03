import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

import 'states_events_transitions.dart';

const int hierarchyDepth = 4;

Logger _log = Logger('machine');

State<E, T, S> createState(
  T back,
  T forward,
  T self,
  T jump, [
  StateMachineWithChangeNotifier<S, E, T>? machine,
]) =>
    State(
      etm: {
        E.back: [back],
        E.forward: [forward],
        E.jump: [T.toA],
        E.self: [self],
        E.jumpBack: [jump]
      },
      onEntry: getEntryAction(),
      regions: [
        if (machine != null) Region<S, E, T, S>(machine: machine),
      ],
    );

StateMachineWithChangeNotifier<S, E, T> createMachine({
  required String name,
  HistoryLevel? historyLevel,
  int level = 0,
}) =>
    StateMachineWithChangeNotifier(
      events: E.values,
      name: name,
      initialStateId: S.a,
      history: historyLevel,
      states: {
        S.a: createState(T.toN, T.toB, T.toA, T.toL),
        S.b: createState(T.toA, T.toC, T.toB, T.toM),
        S.c: createState(T.toB, T.toD, T.toC, T.toN),
        S.d: createState(T.toC, T.toE, T.toD, T.toA),
        S.e: createState(T.toD, T.toF, T.toE, T.toB),
        S.f: createState(T.toE, T.toG, T.toF, T.toC),
        S.g: createState(T.toF, T.toH, T.toG, T.toD),
        S.h: createState(T.toG, T.toI, T.toH, T.toE),
        S.i: createState(T.toH, T.toJ, T.toI, T.toF),
        S.j: createState(T.toI, T.toK, T.toJ, T.toG),
        if (level < hierarchyDepth)
          S.k: createState(
            T.toJ,
            T.toL,
            T.toK,
            T.toH,
            createMachine(
              name: getName(name, S.k),
              level: level + 1,
              historyLevel: historyLevel,
            ),
          )
        else
          S.k: createState(T.toJ, T.toL, T.toK, T.toH),
        if (level < hierarchyDepth)
          S.l: createState(
            T.toK,
            T.toM,
            T.toL,
            T.toI,
            createMachine(
              name: getName(name, S.l),
              level: level + 1,
              historyLevel: historyLevel,
            ),
          )
        else
          S.l: createState(T.toK, T.toM, T.toL, T.toI),
        S.m: createState(T.toL, T.toN, T.toM, T.toJ),
        S.n: createState(T.toM, T.toA, T.toN, T.toK),
      },
      transitions: {
        T.toA: Transition(to: S.a),
        T.toB: Transition(to: S.b),
        T.toC: Transition(to: S.c),
        T.toD: Transition(to: S.d),
        T.toE: Transition(to: S.e),
        T.toF: Transition(to: S.f),
        T.toG: Transition(to: S.g),
        T.toH: Transition(to: S.h),
        T.toI: Transition(to: S.i),
        T.toJ: Transition(to: S.j),
        T.toK: Transition(to: S.k),
        T.toL: Transition(to: S.l),
        T.toM: Transition(to: S.m),
        T.toN: Transition(to: S.n),
      },
    );

Action getEntryAction() => Action(
      description: 'Fire received event.',
      action: (machine, dynamic arg) async {
        if (arg is E) {
          if (arg == E.self) return;
          _log.info(
            () => 'OnEntry: state.machine.fire($arg) - ${machine.name}',
          );
          await machine.fire(arg);
        }
      },
    );

String getName<S>(String current, S stateId) => '$current/$stateId';
