import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
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

List<StateMachine<S, E, T>> getActiveMachines<S, E, T>(
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

void checkTitle<S, E, T>(StateMachine<S, E, T> machine, [S? stateId]) {
  // TODO: Use [] representation of hierarchic states.
  // expect(machine.activeStateId, stateId);

  final activeMachines = getActiveMachines(machine);
  final lm = activeMachines.last;
  final path = getTitle(lm, lm.activeStateId);
  // final path = getTitle(machine, machine.activeStateId);

  // expect(find.text(path), findsOneWidget);
  expect(find.text(path), findsWidgets);
}

enum Act { fire, tap, back }

Future<void> action<S, E, T>(
  StateMachineWithChangeNotifier<S, E, T> machine,
  WidgetTester tester,
  E? event, {
  Act act = Act.tap,
}) async {
  if (act == Act.fire && event != null) {
    await machine.fire(event);
  } else if (act == Act.tap && event != null) {
    await tester.tap(find.text(getButtonTitle(machine, event)).last);
  } else if (act == Act.back) {
    final backButton = find.byType(m.BackButton);
    await tester.tap(backButton);
  } else {
    throw Exception('Unsupported trigger: $act');
  }
  await tester.pumpAndSettle();
}

StateMachineWithChangeNotifier<S, E, T>? _getChildMachine<S, E, T>(
  StateMachineWithChangeNotifier<S, E, T> machine,
) {
  final state = machine.states[machine.activeStateId];
  if (state is State<E, T, S> && state.regions.isNotEmpty) {
    return state.regions[0].machine as StateMachineWithChangeNotifier<S, E, T>;
  } else {
    return null;
  }
}

class Checker<S, E, T> {
  Checker({
    required this.tester,
    required this.act,
    required this.machine,
    required this.mapping,
    this.checkMachine,
  });

  final WidgetTester tester;
  final Act act;
  final StateMachineWithChangeNotifier<S, E, T> machine;
  final Map<S, Presentation> mapping;
  final Future<void> Function(
    WidgetTester tester,
    Act act,
    StateMachineWithChangeNotifier<S, E, T> machine,
    Map<S, Presentation> mapping,
  )? checkMachine;

  Future<void> check(
    E event, {
    Act? act,
    bool titleToBeChecked = true,
  }) async {
    S whereTo(S s, E e) {
      final state = machine.states[s] as State<E, T, S>?;
      final a = state!.etm[e];
      final t = a![0];
      final transition = machine.transitions[t] as Transition<S>?;
      return transition!.to;
    }

    final s = machine.activeStateId;
    if (s == null) throw Exception('Machine ${machine.name} is not started.');
    final expected = whereTo(s, event);
    await action(machine, tester, event, act: act ?? this.act);
    expect(machine.activeStateId, expected);
    final childMachine = _getChildMachine(machine);
    if (childMachine != null && checkMachine != null) {
      await checkMachine!(tester, act ?? this.act, childMachine, mapping);
    } else if (titleToBeChecked) {
      checkTitle(machine);
    }
  }
}
