import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t04_imperative_simple.dart';

import '../../test/aux/aux.dart';

Future<void> main() async {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'StateMachineWithChangeNotifier fire assertion test',
    (tester) async {
      final machine = createLongerMachine();
      await machine.start();
      final app = ImperativeApp(machine);
      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      checkTitle(machine);

      final checker = Checker(
        machine: machine,
        mapping: app.gen.mapping,
        tester: tester,
        checkMachine: checkMachine,
        act: Act.fire,
      );

      await checkMachine(checker);
    },
  );
}

// class ImperativeApp extends StatelessWidget {
//   ImperativeApp(this.machine, {super.key});
//   late final gen = createImperativeGenerator(machine);

//   final StateMachineWithChangeNotifier<S, E, T> machine;
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerDelegate: gen.routerDelegate,
//       routeInformationParser: gen.routeInformationParser,
//     );
//   }
// }

Future<void> checkMachine(Checker<S, E, T> c) async {
  // no_state_change
  await c.check2(E.self);

  // new_presentation_imperative_open
  await c.check2(E.forward);
  await c.check2(E.forward);
  await c.check2(E.forward);

  // new_presentation_page_notify
  await c.check2(E.forward);

  // new_presentation_imperative_open
  await c.check2(E.forward);
  await c.check2(E.forward);
  await c.check2(E.forward);

  // new_presentation_page_notify_overlay
  await c.check2(E.forward);
}
