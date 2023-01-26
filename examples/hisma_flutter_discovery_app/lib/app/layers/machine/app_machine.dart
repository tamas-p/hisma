import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../components/comp_a/layers/machine/comp_a_machine.dart';
import '../../components/comp_f/layers/machine/comp_f_machine.dart';

enum S { a, a1, b, b1, c, d, e, f }

enum E { forward, backward, jump, bigJump }

enum T { toA, toA1, toB, toB1, toC, toD, toE, toF }

final appMachineProvider = Provider((ref) {
  final sm = StateMachineWithChangeNotifier<S, E, T>(
    events: E.values,
    name: 'app',
    initialStateId: S.a,
    states: {
      S.a: State(
        regions: [
          Region<S, E, T, dynamic>(machine: ref.read(compAMachineProvider)),
        ],
        etm: {
          E.forward: [T.toB],
          E.bigJump: [T.toF],
          E.jump: [T.toA1],
        },
      ),
      S.a1: State(
        etm: {
          E.backward: [T.toA],
        },
      ),
      S.b: State(
        etm: {
          E.backward: [T.toA],
          E.forward: [T.toB1],
        },
      ),
      S.b1: State(
        etm: {
          E.backward: [T.toB],
          E.forward: [T.toC],
        },
      ),
      S.c: State(
        etm: {
          E.backward: [T.toB],
          E.forward: [T.toD],
        },
      ),
      S.d: State(
        onEntry: Action(
          description: 'Argument passing test.',
          action: (machine, dynamic arg) async {
            print('ARG: $arg');
          },
        ),
        etm: {
          E.backward: [T.toC],
          E.forward: [T.toE],
          E.jump: [T.toB1]
        },
      ),
      S.e: State(
        etm: {
          E.backward: [T.toD],
          E.jump: [T.toB],
          E.forward: [T.toF]
        },
      ),
      S.f: State(
        regions: [
          Region<S, E, T, dynamic>(machine: ref.read(compFMachineProvider)),
        ],
        etm: {
          E.backward: [T.toE],
          E.jump: [T.toD],
          E.bigJump: [T.toA],
        },
      ),
    },
    transitions: {
      T.toA: Transition(to: S.a),
      T.toA1: Transition(to: S.a1),
      T.toB: Transition(to: S.b),
      T.toB1: Transition(to: S.b1),
      T.toC: Transition(to: S.c),
      T.toD: Transition(to: S.d),
      T.toE: Transition(to: S.e),
      T.toF: Transition(to: S.f),
    },
  );
  return sm;
});
