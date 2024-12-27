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
        childMachine: machine.find<SC, EC, TC>(childMachineName),
      );

      // exit1
      //----------------------------------------------

      await checker.checkParent(E.forward, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      await checker.checkChild(EC.exit1, S.c, null);
      await checker.checkParent(E.forward, S.a, null);

      // TODO: When hot reload when machine is on PagelessCreator it throws
      // LateError (LateInitializationError: Field '_previousPages@95086382'
      // has not been initialized.)
      await checker.checkParent(E.fwd1, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      await checker.checkChild(EC.exit1, S.c, null);
      await checker.checkParent(E.forward, S.a, null);

      await checker.checkParent(E.fwd2, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      await checker.checkChild(EC.exit1, S.c, null);
      await checker.checkParent(E.forward, S.a, null);

      // exit2
      //----------------------------------------------

      await checker.checkParent(E.forward, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      await checker.checkChild(EC.exit2, S.d, null);
      await checker.checkParent(E.forward, S.a, null);

      await checker.checkParent(E.fwd1, S.b, SC.a);
      await checker.checkChild(EC.forward, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      await checker.checkChild(EC.exit2, S.d, null);
      await checker.checkParent(E.forward, S.a, null);

      await checker.checkParent(E.fwd2, S.b, SC.b);
      await checker.checkChild(EC.forward, S.b, SC.c);
      await checker.checkChild(EC.exit2, S.d, null);
      await checker.checkParent(E.forward, S.a, null);
    },
    skip: false,
  );
}

class Checker {
  Checker({
    required this.tester,
    required this.parentMachine,
    required this.childMachine,
  });

  final WidgetTester tester;
  final StateMachineWithChangeNotifier<S, E, T> parentMachine;
  final StateMachineWithChangeNotifier<SC, EC, TC> childMachine;

  Future<void> checkParent(E event, S? parent, SC? child) =>
      _check(parentMachine, event, parent, child);
  Future<void> checkChild(EC event, S? parent, SC? child) =>
      _check(childMachine, event, parent, child);

  Future<void> _check<S, E, T>(
    StateMachineWithChangeNotifier<S, E, T> machine,
    E event,
    S? parent,
    SC? child,
  ) async {
    await action(machine, tester, event);
    expect(parentMachine.activeStateId, parent);
    expect(childMachine.activeStateId, child);
    checkTitle(parentMachine);
  }
}
