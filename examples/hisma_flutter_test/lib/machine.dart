import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

enum S { a, b, c, d, e, f, g, h, i, j, k, l, m, n }

enum E { forward, back, jump, jumpBack, self }

enum T { toA, toB, toC, toD, toE, toF, toG, toH, toI, toJ, toK, toL, toM, toN }

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

StateMachineWithChangeNotifier<S, E, T> createMachine(
  String name, [
  int level = 0,
]) =>
    StateMachineWithChangeNotifier(
      events: E.values,
      name: name,
      initialStateId: S.a,
      history: HistoryLevel.deep,
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
        if (level == 0 || level == 1 || level == 2)
          S.k: createState(
            T.toJ,
            T.toL,
            T.toK,
            T.toH,
            createMachine(
              getName(name, S.k),
              level + 1,
            ),
          )
        else
          S.k: createState(T.toJ, T.toL, T.toK, T.toH),
        if (level == 0 || level == 1 || level == 2)
          S.l: createState(
            T.toK,
            T.toM,
            T.toL,
            T.toI,
            createMachine(
              getName(name, S.l),
              level + 1,
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
          // if (arg == E.back) return;
          print('OnEntry: state.machine.fire($arg) - ${machine.name}');
          await machine.fire(arg);
        }
      },
    );

String getName<S>(String current, S stateId) => '$current/$stateId';