import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter_test/machine.dart';
import 'package:hisma_flutter_test/ui.dart';
import 'package:logging/logging.dart';

void auxInitLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.ALL;
  // Logger(vismaMonitorName).level = Level.INFO;
  // Logger(_loggerName).level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
}

bool isThereBackButton() =>
    find.byTooltip('Back').evaluate().isNotEmpty ||
    find
        .byType(cupertino.CupertinoNavigationBarBackButton)
        .evaluate()
        .isNotEmpty;

Future<void> pageBack(WidgetTester tester) async {
  return TestAsyncUtils.guard<void>(() async {
    var backButton = find.byTooltip('Back').last;
    if (backButton.evaluate().isEmpty) {
      backButton = find.byType(cupertino.CupertinoNavigationBarBackButton);
    }

    expectSync(
      backButton,
      findsOneWidget,
      reason: 'One back button expected on screen',
    );

    await tester.tap(backButton, warnIfMissed: false);
  });
}

List<StateMachine<S, E, T>> getActiveMachines(
  StateMachine<S, E, T> machine,
) {
  final list = <StateMachine<S, E, T>>[];
  if (machine.activeStateId != null) {
    list.add(machine);
    final st = machine.states[machine.activeStateId];
    if (st != null && st is State<E, T, S>) {
      if (st.regions.isNotEmpty) {
        assert(st.regions.length == 1);
        list.addAll(
          getActiveMachines(st.regions.first.machine as StateMachine<S, E, T>),
        );
      }
    }
  }
  return list;
}

void checkTitle(StateMachine<S, E, T> machine, [S? stateId]) {
  // TODO: Use [] representation of hierarchic states.
  // expect(machine.activeStateId, stateId);

  final activeMachines = getActiveMachines(machine);
  final lm = activeMachines.last;

  final path = getTitle(lm, lm.activeStateId);
  expect(find.text(path), findsOneWidget);
}
