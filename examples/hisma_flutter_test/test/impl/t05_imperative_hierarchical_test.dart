import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma_flutter_test/machine_longer.dart';
import 'package:hisma_flutter_test/t05_imperative_hierarchical.dart';

import '../../test/aux/aux.dart';
import 't04_imperative_test.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle the error here, e.g., log the error or fail the test
    print('Unhandled error: ${details.exception}');
    fail('Unhandled error occurred');
  };

  // StateMachine.monitorCreators = [
  //   (m) => VisualMonitor(m, host: '192.168.122.1'),
  // ];
  // auxInitLogging();
  testWidgets(
    'StateMachineWithChangeNotifier test with fire',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1024));
      await testAllStates(tester, act: Act.fire);
    },
  );
  testWidgets(
    'StateMachineWithChangeNotifier test with tap',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1024));
      await testAllStates(tester, act: Act.tap);
    },
  );
}

Future<void> testAllStates(
  WidgetTester tester, {
  required Act act,
}) async {
  final machine = createLongerMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalImperativeApp(machine);
  final box = ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 1000, minWidth: 1000),
    child: app,
  );
  await tester.pumpWidget(box);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await checkMachine(tester, act, machine, app.gen.mapping);
}
