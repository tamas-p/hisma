import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'ui.dart';

Future<void> main(List<String> args) async {
  h.Machine.monitorCreators = [
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

  final NavigationMachine<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createParentGenerator({
  required NavigationMachine<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine),
        ),
        S.b: MaterialPageCreator<E, void>(
          widget: Builder(
            builder: (context) {
              return RouterWithDelegate<SC>(
                () => createChildGenerator(
                  machine: machine.find(childMachineName),
                  rootNavigator: rootNavigator,
                ).routerDelegate,
                key: const ValueKey(S.b),
              );
            },
          ),
        ),
        S.c: MaterialPageCreator<E, void>(
          widget: Screen(machine),
        ),
        S.d: MaterialPageCreator<E, void>(
          widget: Screen(machine),
        ),
        S.e: MaterialPageCreator<E, void>(
          widget: Screen(machine),
        ),
      },
    );

HismaRouterGenerator<SC, EC> createChildGenerator({
  required NavigationMachine<SC, EC, TC> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        SC.a: MaterialPageCreator<EC, void>(
          widget: Screen(machine),
        ),
        SC.b: MaterialPageCreator<EC, void>(
          widget: Screen(machine),
        ),
        SC.c: PagelessCreator<EC, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: EC.back,
        ),
        SC.d: MaterialPageCreator<EC, void>(
          widget: RouterWithDelegate<SGC>(
            () => createGrandChildGenerator(
              machine: machine.find(grandChildMachineName),
              rootNavigator: rootNavigator,
            ).routerDelegate,
            key: const ValueKey(SC.d),
          ),
        ),
      },
    );

HismaRouterGenerator<SGC, EGC> createGrandChildGenerator({
  required NavigationMachine<SGC, EGC, TGC> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        SGC.a: MaterialPageCreator<EGC, void>(
          widget: Screen(machine),
        ),
        SGC.b: MaterialPageCreator<EGC, void>(
          widget: Screen(machine),
        ),
        SGC.c: PagelessCreator<EGC, void>(
          present: showTestDialog,
          rootNavigator: rootNavigator,
          machine: machine,
          event: EGC.forward,
        ),
      },
    );

enum S { a, b, c, d, e }

enum E { forward, fwd1, fwd2, fwd3, ex1, ex2, ex3, back }

enum T { toA, toB, toC, toD, toE }

const parentMachineName = 'parentMachine';
const childMachineName = 'childMachine';
const grandChildMachineName = 'grandChildMachine';

NavigationMachine<S, E, T> createMachine() => NavigationMachine(
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

enum EC { forward, fwd1, fwd2, fwdToError, back, exit1, exit2 }

enum TC { toA, toB, toC, toD, toEx1, toEx2, toEx3 }

NavigationMachine<SC, EC, TC> createChildMachine(String name) =>
    NavigationMachine<SC, EC, TC>(
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
            EC.fwd1: [TC.toD],
            EC.fwd2: [TC.toD],
            EC.fwdToError: [TC.toD],
          },
        ),
        SC.b: h.State(
          etm: {
            EC.forward: [TC.toC],
            EC.fwd1: [TC.toD],
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
            EC.forward: [TC.toEx3],
            EC.back: [TC.toB],
            EC.fwd1: [TC.toC],
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
                h.Trigger(
                  source: SC.a,
                  event: EC.fwd1,
                  transition: TC.toD,
                ): SGC.enA,
                h.Trigger(
                  source: SC.a,
                  event: EC.fwd2,
                  transition: TC.toD,
                ): SGC.enB,
                h.Trigger(
                  source: SC.a,
                  event: EC.fwdToError,
                  transition: TC.toD,
                ): SGC.enC,
              },
              exitConnectors: {
                SGC.ex1: EC.forward,
                SGC.exAll: EC.fwd1,
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

enum SGC { a, b, c, en1, ex1, enA, enB, enC, exAll }

enum EGC { forward }

enum TGC { toA, toB, toC, toExAll, toEx1 }

NavigationMachine<SGC, EGC, TGC> createGrandChildMachine() =>
    NavigationMachine<SGC, EGC, TGC>(
      name: grandChildMachineName,
      events: EGC.values,
      initialStateId: SGC.a,
      states: {
        SGC.en1: h.EntryPoint([TGC.toEx1]),
        SGC.enA: h.EntryPoint([TGC.toA]),
        SGC.enB: h.EntryPoint([TGC.toB]),
        SGC.enC: h.EntryPoint([TGC.toC]),
        SGC.ex1: h.ExitPoint(),
        SGC.exAll: h.ExitPoint(),
        SGC.a: h.State(
          etm: {
            EGC.forward: [TGC.toB],
          },
        ),
        SGC.b: h.State(
          etm: {
            EGC.forward: [TGC.toC],
          },
        ),
        SGC.c: h.State(
          etm: {
            EGC.forward: [TGC.toExAll],
          },
        ),
      },
      transitions: {
        TGC.toEx1: h.Transition(to: SGC.ex1),
        TGC.toA: h.Transition(to: SGC.a),
        TGC.toB: h.Transition(to: SGC.b),
        TGC.toC: h.Transition(to: SGC.c),
        TGC.toExAll: h.Transition(to: SGC.exAll),
      },
    );
