import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

//------

enum L1S {
  s1,
  s2,
}

enum L1E {
  e1,
  e2,
}

enum L1T {
  t1,
  t2,
}

//------

enum L2AS {
  s1,
  s2,
}

enum L2AE {
  e1,
  e2,
}

enum L2AT {
  t1,
  t2,
}

enum L2BS {
  s1,
  s2,
}

enum L2BE {
  e1,
  e2,
}

enum L2BT {
  t1,
  t2,
}

enum L2CS {
  s1,
  s2,
}

enum L2CE {
  e1,
  e2,
}

enum L2CT {
  t1,
  t2,
}

//------

enum L3AS {
  s1,
  s2,
}

enum L3AE {
  e1,
  e2,
}

enum L3AT {
  t1,
  t2,
}

enum L3BS {
  s1,
  s2,
}

enum L3BE {
  e1,
  e2,
}

enum L3BT {
  t1,
  t2,
}

enum L3CS {
  s1,
  s2,
}

enum L3CE {
  e1,
  e2,
}

enum L3CT {
  t1,
  t2,
}

enum L3DS {
  s1,
  s2,
}

enum L3DE {
  e1,
  e2,
}

enum L3DT {
  t1,
  t2,
}

enum L3ES {
  s1,
  s2,
}

enum L3EE {
  e1,
  e2,
}

enum L3ET {
  t1,
  t2,
}

enum L3FS {
  s1,
  s2,
}

enum L3FE {
  e1,
  e2,
}

enum L3FT {
  t1,
  t2,
}

//------

Machine<L3AS, L3AE, L3AT> smL3A() => Machine<L3AS, L3AE, L3AT>(
      name: 'smL3A',
      initialStateId: L3AS.s1,
      states: {
        L3AS.s1: State(
          etm: {
            L3AE.e1: [L3AT.t1],
          },
        ),
        L3AS.s2: State(
          etm: {
            L3AE.e2: [L3AT.t2],
          },
        ),
      },
      transitions: {
        L3AT.t1: Transition(to: L3AS.s2),
        L3AT.t2: Transition(to: L3AS.s1),
      },
    );

Machine<L3BS, L3BE, L3BT> smL3B() => Machine<L3BS, L3BE, L3BT>(
      name: 'smL3B',
      initialStateId: L3BS.s1,
      states: {
        L3BS.s1: State(
          etm: {
            L3BE.e1: [L3BT.t1],
          },
        ),
        L3BS.s2: State(
          etm: {
            L3BE.e2: [L3BT.t2],
          },
        ),
      },
      transitions: {
        L3BT.t1: Transition(to: L3BS.s2),
        L3BT.t2: Transition(to: L3BS.s1),
      },
    );

Machine<L3CS, L3CE, L3CT> smL3C() => Machine<L3CS, L3CE, L3CT>(
      name: 'smL3C',
      initialStateId: L3CS.s1,
      states: {
        L3CS.s1: State(
          etm: {
            L3CE.e1: [L3CT.t1],
          },
        ),
        L3CS.s2: State(
          etm: {
            L3CE.e2: [L3CT.t2],
          },
        ),
      },
      transitions: {
        L3CT.t1: Transition(to: L3CS.s2),
        L3CT.t2: Transition(to: L3CS.s1),
      },
    );

Machine<L3DS, L3DE, L3DT> smL3D() => Machine<L3DS, L3DE, L3DT>(
      name: 'smL3D',
      initialStateId: L3DS.s1,
      states: {
        L3DS.s1: State(
          etm: {
            L3DE.e1: [L3DT.t1],
          },
        ),
        L3DS.s2: State(
          etm: {
            L3DE.e2: [L3DT.t2],
          },
        ),
      },
      transitions: {
        L3DT.t1: Transition(to: L3DS.s2),
        L3DT.t2: Transition(to: L3DS.s1),
      },
    );

Machine<L3ES, L3EE, L3ET> smL3E() => Machine<L3ES, L3EE, L3ET>(
      name: 'smL3E',
      initialStateId: L3ES.s1,
      states: {
        L3ES.s1: State(
          etm: {
            L3EE.e1: [L3ET.t1],
          },
        ),
        L3ES.s2: State(
          etm: {
            L3EE.e2: [L3ET.t2],
          },
        ),
      },
      transitions: {
        L3ET.t1: Transition(to: L3ES.s2),
        L3ET.t2: Transition(to: L3ES.s1),
      },
    );

Machine<L3FS, L3FE, L3FT> smL3F() => Machine<L3FS, L3FE, L3FT>(
      name: 'smL3F',
      initialStateId: L3FS.s1,
      states: {
        L3FS.s1: State(
          etm: {
            L3FE.e1: [L3FT.t1],
          },
        ),
        L3FS.s2: State(
          etm: {
            L3FE.e2: [L3FT.t2],
          },
        ),
      },
      transitions: {
        L3FT.t1: Transition(to: L3FS.s2),
        L3FT.t2: Transition(to: L3FS.s1),
      },
    );

Machine<L2AS, L2AE, L2AT> smL2A(
  Machine<L3AS, L3AE, L3AT> smL3A,
  Machine<L3BS, L3BE, L3BT> smL3B,
) =>
    Machine<L2AS, L2AE, L2AT>(
      name: 'smL2A',
      initialStateId: L2AS.s1,
      states: {
        L2AS.s1: State(
          etm: {
            L2AE.e1: [L2AT.t1],
          },
          regions: [
            Region(machine: smL3A),
            Region(machine: smL3B),
          ],
        ),
        L2AS.s2: State(
          etm: {
            L2AE.e2: [L2AT.t2],
          },
        ),
      },
      transitions: {
        L2AT.t1: Transition(to: L2AS.s2),
        L2AT.t2: Transition(to: L2AS.s1),
      },
    );

Machine<L2BS, L2BE, L2BT> smL2B(
  Machine<L3CS, L3CE, L3CT> smL3C,
  Machine<L3DS, L3DE, L3DT> smL3D,
) =>
    Machine<L2BS, L2BE, L2BT>(
      name: 'smL2B',
      initialStateId: L2BS.s1,
      states: {
        L2BS.s1: State(
          etm: {
            L2BE.e1: [L2BT.t1],
          },
          regions: [
            Region(machine: smL3C),
            Region(machine: smL3D),
          ],
        ),
        L2BS.s2: State(
          etm: {
            L2BE.e2: [L2BT.t2],
          },
        ),
      },
      transitions: {
        L2BT.t1: Transition(to: L2BS.s2),
        L2BT.t2: Transition(to: L2BS.s1),
      },
    );

Machine<L2CS, L2CE, L2CT> smL2C(
  Machine<L3ES, L3EE, L3ET> smL3E,
  Machine<L3FS, L3FE, L3FT> smL3F,
) =>
    Machine<L2CS, L2CE, L2CT>(
      name: 'smL2C',
      initialStateId: L2CS.s1,
      states: {
        L2CS.s1: State(
          etm: {
            L2CE.e1: [L2CT.t1],
          },
          regions: [
            Region(machine: smL3E),
            Region(machine: smL3F),
          ],
        ),
        L2CS.s2: State(
          etm: {
            L2CE.e2: [L2CT.t2],
          },
        ),
      },
      transitions: {
        L2CT.t1: Transition(to: L2CS.s2),
        L2CT.t2: Transition(to: L2CS.s1),
      },
    );

Machine<L1S, L1E, L1T> smL1(
  Machine<L2AS, L2AE, L2AT> smL2A,
  Machine<L2BS, L2BE, L2BT> smL2B,
  Machine<L2CS, L2CE, L2CT> smL3C,
) =>
    Machine<L1S, L1E, L1T>(
      name: 'smL1',
      initialStateId: L1S.s1,
      states: {
        L1S.s1: State(
          etm: {
            L1E.e1: [L1T.t1],
          },
        ),
        L1S.s2: State(
          etm: {
            L1E.e2: [L1T.t2],
          },
          regions: [
            Region(machine: smL2A),
            Region(machine: smL2B),
            Region(machine: smL3C),
          ],
        ),
      },
      transitions: {
        L1T.t1: Transition(to: L1S.s2),
        L1T.t2: Transition(to: L1S.s1),
      },
    );

Future<void> fireAndCheck(
  Machine<L1S, L1E, L1T> sm,
  L1E event,
  List<dynamic> expectedState,
) async {
  await expectLater(
    sm.fire(event),
    completion(equals(null)),
  );

  expect(
    sm.getActiveStateRecursive(),
    equals(expectedState),
  );
}
