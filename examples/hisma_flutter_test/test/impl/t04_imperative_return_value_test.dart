import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/t04_imperative_return_value.dart';
import 'package:hisma_flutter_test/ui.dart';

import '../aux/aux.dart';

Future<void> main() async {
  // Machine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'Imperative return value test.',
    (tester) async {
      await checkMachine(tester);
    },
  );
}

Future<void> checkMachine(WidgetTester tester) async {
  final machine = createReturnValueMachine();
  await machine.start();
  final app = ReturnValueApp(machine: machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  Future<void> forward() async {
    await tester.tap(find.text(getButtonTitle(machine, E.forward)));
    await tester.pumpAndSettle();
    expect(machine.activeStateId, S.b);
    expect(machine.data, equals(null));

    await tester.tap(find.text(getButtonTitle(machine, E.forward)));
    await tester.pumpAndSettle();
    expect(machine.activeStateId, S.c);
    expect(machine.data, equals(null));

    await tester.tap(find.text('Forward'));
    await tester.pumpAndSettle();
    expect(machine.activeStateId, S.d);
    expect(machine.data, equals(null));
  }

  Future<void> backward() async {
    // await tester.tap(find.text('CANCEL'));
    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Text && widget.data?.toLowerCase() == 'cancel',
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(machine.activeStateId, S.c);
    expect(machine.data, equals(null));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(machine.activeStateId, S.b);
    expect(machine.data, equals(null));

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(machine.activeStateId, S.a);
    expect(machine.data, equals(null));
  }

  expect(machine.data, equals(null));

  await forward();
  await backward();
  await forward();

  await tester.tap(find.text('OK').last);
  await tester.pumpAndSettle();
  expect(machine.activeStateId, S.c);
  expect(machine.data, isA<DateTime>());

  await tester.tap(find.text('OK').last);
  await tester.pumpAndSettle();
  expect(machine.activeStateId, S.b);
  expect(machine.data, Returned.okFromDialog);

  await tester.tap(find.text('OK').last);
  await tester.pumpAndSettle();
  expect(machine.activeStateId, S.a);
  expect(machine.data, Returned.okFromOverlay);
}
