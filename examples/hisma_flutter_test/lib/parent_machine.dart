import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import 'machine.dart';
import 'states_events_transitions.dart';

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
          regions: [Region<S, E, T, S>(machine: createMachine(name: 't1'))],
        ),
        S.c: createState(),
        S.d: createState(),
      },
      transitions: {},
    );
