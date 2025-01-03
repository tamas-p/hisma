import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'ui.dart';

Future<void> main(List<String> args) async {
  h.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createMachine();
  await machine.start();

  runApp(EntryExitApp(machine: machine, rootNavigator: true));
}

class EntryExitApp extends StatelessWidget {
  EntryExitApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final gen =
      createParentGenerator(machine: machine, rootNavigator: rootNavigator);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createParentGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.a),
        ),
        S.b: MaterialPageCreator<E, void>(
          widget: Builder(
            builder: (context) {
              return Router<SC>(
                routerDelegate: createChildGenerator(
                  machine: machine.find(childMachineName),
                  rootNavigator: rootNavigator,
                ).routerDelegate,
                backButtonDispatcher: Router.of(context)
                    .backButtonDispatcher!
                    .createChildBackButtonDispatcher()
                  ..takePriority(),
              );
            },
          ),
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.c),
        ),
        S.d: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.d),
        ),
        S.e: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.e),
        ),
      },
    );

HismaRouterGenerator<SC, EC> createChildGenerator({
  required StateMachineWithChangeNotifier<SC, EC, TC> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        SC.a: MaterialPageCreator<EC, void>(
          widget: Screen(machine, SC.a),
        ),
        SC.b: MaterialPageCreator<EC, void>(
          widget: Screen(machine, SC.b),
        ),
        SC.c: PagelessCreator<EC, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: EC.back,
        ),
      },
    );

enum S { a, b, c, d, e }

enum E { forward, fwd1, fwd2, fwd3, ex1, ex2, ex3, back }

enum T { toA, toB, toC, toD, toE }

const parentMachineName = 'parentMachine';
const childMachineName = 'childMachine';

StateMachineWithChangeNotifier<S, E, T> createMachine() =>
    StateMachineWithChangeNotifier(
      name: parentMachineName,
      events: E.values,
      initialStateId: S.a,
      states: {
        S.a: h.State(
          etm: {
            E.forward: [T.toB],
            E.fwd1: [T.toB],
            E.fwd2: [T.toB],
            E.fwd3: [T.toB],
          },
        ),
        S.b: h.State(
          etm: {
            E.ex1: [T.toC],
            E.ex2: [T.toD],
            E.ex3: [T.toE],
          },
          regions: [
            h.Region<S, E, T, SC>(
              machine: createChildMachine(childMachineName),
              entryConnectors: {
                h.Trigger(source: S.a, event: E.fwd1, transition: T.toB):
                    SC.en1,
                h.Trigger(source: S.a, event: E.fwd2, transition: T.toB):
                    SC.en2,
                h.Trigger(source: S.a, event: E.fwd3, transition: T.toB):
                    SC.en3,
              },
              exitConnectors: {
                SC.ex1: E.ex1,
                SC.ex2: E.ex2,
                SC.ex3: E.ex3,
              },
            ),
          ],
        ),
        S.c: h.State(
          etm: {
            E.forward: [T.toA],
          },
        ),
        S.d: h.State(
          etm: {
            E.forward: [T.toA],
          },
        ),
        S.e: h.State(
          etm: {
            E.forward: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(to: S.a),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
        T.toE: h.Transition(to: S.e),
      },
    );

enum SC { a, b, c, d, en1, en2, en3, ex1, ex2, ex3 }

enum EC { forward, back, exit1, exit2 }

enum TC { toA, toB, toC, toD, toEx1, toEx2, toEx3 }

StateMachineWithChangeNotifier<SC, EC, TC> createChildMachine(String name) =>
    StateMachineWithChangeNotifier<SC, EC, TC>(
      name: name,
      events: EC.values,
      initialStateId: SC.a,
      states: {
        SC.en1: h.EntryPoint([TC.toA]),
        SC.en2: h.EntryPoint([TC.toB]),
        SC.en3: h.EntryPoint([TC.toD]),
        SC.a: h.State(
          etm: {
            EC.forward: [TC.toB],
          },
        ),
        SC.b: h.State(
          etm: {
            EC.forward: [TC.toC],
          },
        ),
        SC.c: h.State(
          etm: {
            EC.back: [TC.toB],
            EC.forward: [TC.toA],
            EC.exit1: [TC.toEx1],
            EC.exit2: [TC.toEx2],
          },
        ),
        SC.d: h.State(
          etm: {
            EC.forward: [TC.toEx3]
          },
          regions: [
            h.Region<SC, EC, TC, SGC>(
              machine: createGrandChildMachine(),
              entryConnectors: {
                h.Trigger(
                  source: SC.en3,
                  event: null,
                  transition: TC.toD,
                ): SGC.en1,
              },
              exitConnectors: {
                SGC.ex1: EC.forward,
              },
            ),
          ],
        ),
        SC.ex1: h.ExitPoint(),
        SC.ex2: h.ExitPoint(),
        SC.ex3: h.ExitPoint(),
      },
      transitions: {
        TC.toA: h.Transition(to: SC.a),
        TC.toB: h.Transition(to: SC.b),
        TC.toC: h.Transition(to: SC.c),
        TC.toD: h.Transition(to: SC.d),
        TC.toEx1: h.Transition(to: SC.ex1),
        TC.toEx2: h.Transition(to: SC.ex2),
        TC.toEx3: h.Transition(to: SC.ex3),
      },
    );

enum SGC { en1, ex1 }

enum EGC { forward }

enum TGC { toEx1 }

StateMachineWithChangeNotifier<SGC, EGC, TGC> createGrandChildMachine() =>
    StateMachineWithChangeNotifier<SGC, EGC, TGC>(
      name: 'grandChildMachine',
      events: EGC.values,
      initialStateId: SGC.en1,
      states: {
        SGC.en1: h.EntryPoint([TGC.toEx1]),
        SGC.ex1: h.ExitPoint(),
      },
      transitions: {
        TGC.toEx1: h.Transition(to: SGC.ex1),
      },
    );
