import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/simple_machine.dart';
import 'package:hisma_flutter_test/ui.dart';

void main() {
  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'StateMachineWithChangeNotifier fire assertion test',
    (tester) async {
      final machine = createSimpleMachine();
      await machine.start();
      final app = ImperativeApp(machine);
      await tester.pumpWidget(app);
    },
  );
}

class ImperativeApp extends StatelessWidget {
  ImperativeApp(this.machine, {super.key});
  late final gen = createImperativeGenerator(machine);

  final StateMachineWithChangeNotifier<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

HismaRouterGenerator<S, E> createImperativeGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine,
) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.a),
          event: E.back,
        ),
        S.b: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.back,
        ),
        S.c: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.forward,
        ),
        S.d: PagelessCreator<E, void>(
          present: showTestDialog,
          machine: machine,
          event: E.forward,
        ),
      },
    );
