import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

Future<void> main(List<String> args) async {
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
    (machine) => ConsoleMonitor(machine),
  ];
  await sm.start();
  // sm.fire(E.e1);
  // sm.fire(E.e2);
  // sm.fire(E.e2);

  // sm1.start();
  // sm1.fire('something');
}

//------------------------------------------------------------------------------
// Parent machine
//------------------------------------------------------------------------------
enum S { en1, s1, s2, ex1 }

enum E { e1, e2 }

enum T { t1, t2, t3 }

final sm = StateMachine<S, E, T>(
  events: E.values,
  name: 'm1',
  initialStateId: S.s1,
  states: {
    S.en1: EntryPoint([T.t2]),
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
        Region<S, E, T, SS>(
          machine: ssm,
          entryConnectors: {
            Trigger(source: S.s1, event: E.e1, transition: T.t1): SS.en1,
          },
          exitConnectors: {
            SS.ex1: E.e2,
          },
        ),
      ],
    ),
    S.ex1: ExitPoint(),
  },
  transitions: {
    T.t1: Transition(to: S.s2),
    T.t2: Transition(to: S.s1),
    T.t3: Transition(to: S.ex1),
  },
);

//------------------------------------------------------------------------------
// Child machine
//------------------------------------------------------------------------------
enum SS { en1, s1, s2, ex1 }

enum SE { e1, e2, e3 }

enum ST { t0, t1, t2, t3 }

final ssm = StateMachine<SS, SE, ST>(
  events: SE.values,
  name: 'cm1',
  initialStateId: SS.s1,
  states: {
    SS.en1: EntryPoint([ST.t1]),
    SS.s1: State(
      etm: {
        SE.e1: [ST.t1],
        SE.e3: [ST.t3],
      },
    ),
    SS.s2: State(
      etm: {
        SE.e2: [ST.t2],
      },
    ),
    SS.ex1: ExitPoint(),
  },
  // Why Transitions are at this level?
  transitions: {
    ST.t0: Transition(to: SS.en1),
    ST.t1: Transition(to: SS.s2),
    ST.t2: Transition(to: SS.s1),
    ST.t3: Transition(to: SS.ex1),
  },
);

//------------------------------------------------------------------------------

final sm1 = StateMachine<String, String, String>(
  name: 'm2',
  states: {
    's1': State(),
  },
  transitions: {},
  initialStateId: 'something',
);

//------------------------------------------------------------------------------

