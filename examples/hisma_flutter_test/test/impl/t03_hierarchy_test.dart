import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/simple_machine.dart';
import 'package:hisma_flutter_test/t03_hierarchical.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

// import '../../test/aux/aux.dart';

enum Act { fire, tap, back }

void main() {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  // auxInitLogging();
  testWidgets(
    'overlay test with direct fire',
    (tester) async {
      await testAllStates(tester, act: Act.fire);
    },
  );
  testWidgets(
    'overlay test with taps',
    (tester) async {
      await testAllStates(tester, act: Act.tap);
    },
  );
}

Future<void> testAllStates(
  WidgetTester tester, {
  required Act act,
}) async {
  final machine = createSimpleMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalApp(machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);

  await checkMachine(tester, act, machine, app.generator.mapping);
}

Future<void> checkMachine(
  WidgetTester tester,
  Act act,
  StateMachineWithChangeNotifier<S, E, T> machine,
  Map<S, Presentation> mapping,
) async {
  final c = Checker(
    tester: tester,
    act: act,
    machine: machine,
    mapping: mapping,
    checkMachine: checkMachine,
  );

  for (var i = 0; i < machine.states.length; i++) {
    await c.check(E.self, act: act);
    await c.check(E.forward, act: act);

    final presentation = mapping[machine.activeStateId];
    final overlay = presentation is PageCreator && presentation.overlay;
    if (overlay) {
      await c.check(E.back, act: Act.back);
    } else {
      await c.check(E.back, act: act);
    }

    await c.check(E.self, act: act);

    // presentation = mapping[machine.activeStateId];
    // overlay = presentation is PageCreator && presentation.overlay;
    // if (overlay) {
    // await _check(machine, tester, E.back, mapping, act: Act.back);
    // } else {
    await c.check(E.back, act: act);
    // }

    await c.check(E.self, act: act);
    await c.check(E.forward, act: act);
    await c.check(E.self, act: act);
    await c.check(E.forward, act: act);
  }
}

class Checker {
  Checker({
    required this.tester,
    required this.act,
    required this.machine,
    required this.mapping,
    required this.checkMachine,
  });

  final WidgetTester tester;
  final Act act;
  final StateMachineWithChangeNotifier<S, E, T> machine;
  final Map<S, Presentation> mapping;
  Future<void> Function(
    WidgetTester tester,
    Act act,
    StateMachineWithChangeNotifier<S, E, T> machine,
    Map<S, Presentation> mapping,
  ) checkMachine;
  Future<void> check(
    E event, {
    Act act = Act.tap,
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

    await action(machine, tester, event, act: act);
    expect(machine.activeStateId, expected);

    final childMachine = _getChildMachine(machine);
    if (childMachine != null) {
      await checkMachine(tester, act, childMachine, mapping);
    } else {
      checkTitle(machine);
    }
  }
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

Future<void> action<S, E, T>(
  StateMachineWithChangeNotifier<S, E, T> machine,
  WidgetTester tester,
  E? event, {
  Act act = Act.tap,
}) async {
  if (act == Act.fire && event != null) {
    await machine.fire(event);
    // We need this extra pumpAndSettle as pageless routes are created in a
    // subsequent frame by Future.delayed.
    // TODO: Remove this as new design will not use Future.delayed.
    await tester.pumpAndSettle();
  } else if (act == Act.tap && event != null) {
    await tester.tap(find.text(getButtonTitle(machine, event)).first);
  } else if (act == Act.back) {
    final backButton = find.byType(m.BackButton);
    await tester.tap(backButton);
  } else {
    throw Exception('Unsupported trigger: $act');
  }
  await tester.pumpAndSettle();
}

void checkTitle<S, E, T>(StateMachine<S, E, T> machine, [S? stateId]) {
  // TODO: Use [] representation of hierarchic states.
  // expect(machine.activeStateId, stateId);

  // final activeMachines = getActiveMachines(machine);
  // final lm = activeMachines.last;
  // final path = getTitle(lm, lm.activeStateId);
  final path = getTitle(machine, machine.activeStateId);

  expect(find.text(path), findsOneWidget);
}

String getTitle(
  StateMachine<dynamic, dynamic, dynamic> machine,
  dynamic stateId,
) =>
    '${machine.name} - $stateId';

String getButtonTitle<S, E, T>(
  StateMachine<S, E, T> machine,
  dynamic event,
) =>
    '${machine.name}.$event';
