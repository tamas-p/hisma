import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/t04_imperative_fire_arg.dart';

void main() {
  testWidgets(
    'Imperative fire arg test.',
    (tester) async {
      final machine = createImperativeFireArgMachine();
      await machine.start();
      final app = ImperativeFireArgApp(machine: machine);
      await tester.pumpWidget(app);
      expect(machine.activeStateId, machine.initialStateId);
      expect(find.text(title), findsOneWidget);

      Future<void> check(dynamic arg) async {
        await machine.fire(E.forward, arg: arg);
        await tester.pumpAndSettle();
        expect(machine.activeStateId, S.b);
        expect(find.textContaining(arg.toString()), findsOneWidget);

        await machine.fire(E.backward);
        await tester.pumpAndSettle();
        expect(machine.activeStateId, S.a);
        expect(find.text(title), findsOneWidget);
      }

      await check(null);
      await check(string);
      await check(integer);
      await check(doubleNum);
      await check(object);
      await check({'key': 'value'});
      await check([1, 2, 3]);
      await check((int x) => x * x);
      await check(const {'a', 'b', 'c'});
      await check(DateTime);
    },
  );
}
