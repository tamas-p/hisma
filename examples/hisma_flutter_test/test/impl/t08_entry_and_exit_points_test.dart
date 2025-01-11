import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/t08_entry_and_exit_points.dart';

import '../aux/aux.dart';

Future<void> main() async {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  //   (m) => ConsoleMonitor(m),
  // ];
  // auxInitLogging();

  testWidgets(
    'Entry and exit points',
    (tester) async {
      final machine = createMachine();
      await machine.start();
      final app = EntryExitApp(machine: machine, rootNavigator: false);

      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      checkTitle(machine);

      final checker = Checker(
        tester: tester,
        parentMachine: machine,
      );

      // exit1
      //----------------------------------------------

      await checker.checkParent(E.forward, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      // test: stopped_machine
      await checker.checkChild(EC.exit1, S.c);
      await checker.checkParent(E.forward, S.a);

      await checker.checkParent(E.fwd1, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      // test: stopped_machine
      await checker.checkChild(EC.exit1, S.c);
      await checker.checkParent(E.forward, S.a);

      await checker.checkParent(E.fwd2, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      // test: stopped_machine
      await checker.checkChild(EC.exit1, S.c);
      await checker.checkParent(E.forward, S.a);

      // exit2
      //----------------------------------------------

      await checker.checkParent(E.forward, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      // test: stopped_machine
      await checker.checkChild(EC.exit2, S.d);
      await checker.checkParent(E.forward, S.a);

      await checker.checkParent(E.fwd1, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      // test: stopped_machine
      await checker.checkChild(EC.exit2, S.d);
      await checker.checkParent(E.forward, S.a);

      await checker.checkParent(E.fwd2, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      // test: stopped_machine
      await checker.checkChild(EC.exit2, S.d);
      await checker.checkParent(E.forward, S.a);
    },
    skip: false,
  );

  testWidgets('Passthrough child and grandchild.', (tester) async {
    final parentMachine = createMachine();
    await parentMachine.start();
    final app = EntryExitApp(machine: parentMachine, rootNavigator: false);

    await tester.pumpWidget(app);
    expect(parentMachine.activeStateId, parentMachine.initialStateId);
    checkTitle(parentMachine);

    final checker = Checker(
      tester: tester,
      parentMachine: parentMachine,
    );

    await checker.checkParent(E.fwd3, S.e);
  });

  testWidgets('Walk through grandchild.', (tester) async {
    final parentMachine = createMachine();
    await parentMachine.start();
    final app = EntryExitApp(machine: parentMachine, rootNavigator: false);

    await tester.pumpWidget(app);
    expect(parentMachine.activeStateId, parentMachine.initialStateId);
    checkTitle(parentMachine);

    final checker = Checker(
      tester: tester,
      parentMachine: parentMachine,
    );

    await checker.checkParent(E.forward, S.b, SC.a);

    // Through forward
    await checker.checkChild(EC.forward, S.b, SC.b);
    await checker.checkChild(EC.fwd1, S.b, SC.d, SGC.a);
    await checker.checkGrandChild(EGC.forward, S.b, SC.d, SGC.b);
    await checker.checkGrandChild(EGC.forward, S.b, SC.d, SGC.c);
    await checker.checkGrandChild(EGC.forward, S.b, SC.c);
    await checker.checkChild(EC.forward, S.b, SC.a);

    // Through fwd1
    await checker.checkChild(EC.fwd1, S.b, SC.d, SGC.a);
    await checker.checkGrandChild(EGC.forward, S.b, SC.d, SGC.b);
    await checker.checkGrandChild(EGC.forward, S.b, SC.d, SGC.c);
    await checker.checkGrandChild(EGC.forward, S.b, SC.c);
    await checker.checkChild(EC.forward, S.b, SC.a);

    // Through fwd2
    await checker.checkChild(EC.fwd2, S.b, SC.d, SGC.b);
    await checker.checkGrandChild(EGC.forward, S.b, SC.d, SGC.c);
    await checker.checkGrandChild(EGC.forward, S.b, SC.c);
    await checker.checkChild(EC.forward, S.b, SC.a);
  });

  testWidgets('Assert on empty _previousPages', (tester) async {
    final parentMachine = createMachine();
    await parentMachine.start();
    final app = EntryExitApp(machine: parentMachine, rootNavigator: false);

    await tester.pumpWidget(app);
    expect(parentMachine.activeStateId, parentMachine.initialStateId);
    checkTitle(parentMachine);

    final checker = Checker(
      tester: tester,
      parentMachine: parentMachine,
    );

    await checker.checkParent(E.forward, S.b, SC.a);
    await expectThrow<AssertionError>(
      () async {
        await action(checker.childMachine, tester, EC.fwdToError);
      },
      assertText: 'No previous pages.',
    );
  });
}

class Checker {
  Checker({
    required this.tester,
    required this.parentMachine,
  })  : grandChildMachine =
            parentMachine.find<SGC, EGC, TGC>(grandChildMachineName),
        childMachine = parentMachine.find<SC, EC, TC>(childMachineName);

  final WidgetTester tester;
  final NavigationMachine<S, E, T> parentMachine;
  final NavigationMachine<SC, EC, TC> childMachine;
  final NavigationMachine<SGC, EGC, TGC> grandChildMachine;

  Future<void> checkParent(E event, S? parent, [SC? child, SGC? gc]) =>
      _check(parentMachine, event, parent, child, gc);
  Future<void> checkChild(EC event, S? parent, [SC? child, SGC? gc]) =>
      _check(childMachine, event, parent, child, gc);
  Future<void> checkGrandChild(EGC event, S? parent, [SC? child, SGC? gc]) =>
      _check(grandChildMachine, event, parent, child, gc);

  Future<void> _check<S, E, T>(
    NavigationMachine<S, E, T> machine,
    E event,
    S? parent, [
    SC? child,
    SGC? gc,
  ]) async {
    await action(machine, tester, event);
    expect(parentMachine.activeStateId, parent);
    expect(childMachine.activeStateId, child);
    expect(grandChildMachine.activeStateId, gc);
    checkTitle(parentMachine);
  }
}
