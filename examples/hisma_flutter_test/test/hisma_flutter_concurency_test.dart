import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/concurrent_fire.dart';

Future<void> main() async {
  testWidgets(
    'Concurrency test.',
    (tester) async {
      final machine = createConcurrentMachine();
      await machine.start();

      await tester.pumpWidget(DoubleApp(machine: machine));
      expect(
        find.text('sub1 screen'),
        findsOneWidget,
      );
      expect(
        find.text('sub2 screen'),
        findsOneWidget,
      );

      expect(
        find.text('Sub1'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Sub1'),
        warnIfMissed: false,
      );
      // await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(
        find.text('Sub2'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(
        find.text('BottomSheet: Sub1'),
        findsOneWidget,
      );
      expect(
        find.text('BottomSheet: Sub2'),
        findsOneWidget,
      );
    },
  );
  testWidgets('BottomSheet test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              showBottomSheet<void>(
                context: tester.element(find.byType(ElevatedButton)),
                builder: (BuildContext context) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('Content inside BottomSheet'),
                    ),
                  );
                },
              );
            },
            child: const Text('Open BottomSheet'),
          ),
        ),
      ),
    );

    // Ensure the BottomSheet is closed initially.
    expect(find.text('Content inside BottomSheet'), findsNothing);

    // Tap the button to open the BottomSheet.
    await tester.tap(find.text('Open BottomSheet'));
    await tester.pump();

    // Ensure the BottomSheet is open and contains the desired content.
    expect(find.text('Content inside BottomSheet'), findsOneWidget);
  });
}
