import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import 'machine.dart' as child;

enum S { a, b, c, d }

enum E { forward, back, self, jump }

enum T { toA, toB, toC, toD }

const String parentMachineName = 'parentMachineName';

State<E, T, S> createState() => State();

StateMachineWithChangeNotifier<S, E, T> createParentMachine() =>
    StateMachineWithChangeNotifier(
      events: E.values,
      name: parentMachineName,
      initialStateId: S.a,
      states: {
        S.a: createState(),
        S.b: State(
          regions: [
            Region<S, E, T, child.S>(machine: child.createMachine(name: 't1'))
          ],
        ),
        S.c: createState(),
        S.d: createState(),
      },
      transitions: {},
    );
