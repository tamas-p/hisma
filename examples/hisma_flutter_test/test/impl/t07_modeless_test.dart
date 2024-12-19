import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:hisma_flutter_test/t07_modeless.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

Future<void> main() async {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
    (m) => ConsoleMonitor(m),
  ];
  // auxInitLogging();
  testWidgets(
    'Modeless test',
    (tester) async {
      final machine = createMachine();
      await machine.start();
      final app = BottomSheetApp(machine: machine, rootNavigator: true);
      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      expect(find.text(mainAppScreenTitle), findsWidgets);

      await ttt(tester, E.fwdB, modelessBottomSheetText);
      await ttt(tester, E.fwdC, modalBottomSheetText);
      await ttt(tester, E.fwdD, snackBarText);
    },
    skip: false,
  );
}

Future<void> ttt(WidgetTester tester, E event, String expected) async {
  await tester.tap(find.text(event.toString()));
  await tester.pumpAndSettle();
  expect(find.text(mainAppScreenTitle), findsWidgets);
  expect(find.text(expected), findsWidgets);

  await tester.tap(find.text(closeButtonTitle));
  await tester.pumpAndSettle();
  expect(find.text(mainAppScreenTitle), findsWidgets);
  expect(find.text(expected), findsNothing);
}
