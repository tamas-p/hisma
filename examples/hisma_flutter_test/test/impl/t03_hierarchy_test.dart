import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_flutter_test/simple_machine.dart';
import 'package:hisma_flutter_test/t03_hierarchical.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../aux/aux.dart';

void main() {
  StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  auxInitLogging();
  testWidgets(
    'overlay test with direct fire',
    (tester) async {
      await checkAllStates(tester, act: Act.fire);
    },
  );
  testWidgets(
    'overlay test with taps',
    (tester) async {
      await checkAllStates(tester, act: Act.tap);
    },
  );
}

Future<void> checkAllStates(
  WidgetTester tester, {
  required Act act,
}) async {
  final machine = createSimpleMachine(hierarchical: true);
  await machine.start();
  final app = HierarchicalApp(machine);
  await tester.pumpWidget(app);
  expect(machine.activeStateId, machine.initialStateId);
  checkTitle(machine);
  await checkMachine(
    tester: tester,
    act: act,
    machine: machine,
    mapping: app.generator.mapping,
  );
}

Future<void> checkMachine({
  required WidgetTester tester,
  required Act act,
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required Map<S, Presentation> mapping,
}) async {
  for (var i = 0; i < machine.states.length; i++) {
    await _check(machine, tester, E.self, mapping, act: act);
    await _check(machine, tester, E.forward, mapping, act: act);

    final presentation = mapping[machine.activeStateId];
    final overlay = presentation is PageCreator && presentation.overlay;
    if (overlay) {
      await _check(machine, tester, E.back, mapping, act: Act.back);
    } else {
      await _check(machine, tester, E.back, mapping, act: act);
    }

    await _check(machine, tester, E.self, mapping, act: act);

    // presentation = mapping[machine.activeStateId];
    // overlay = presentation is PageCreator && presentation.overlay;
    // if (overlay) {
    // await _check(machine, tester, E.back, mapping, act: Act.back);
    // } else {
    await _check(machine, tester, E.back, mapping, act: act);
    // }

    await _check(machine, tester, E.self, mapping, act: act);
    await _check(machine, tester, E.forward, mapping, act: act);
    await _check(machine, tester, E.self, mapping, act: act);
    await _check(machine, tester, E.forward, mapping, act: act);
  }
}

Future<void> _check(
  StateMachineWithChangeNotifier<S, E, T> machine,
  WidgetTester tester,
  E event,
  Map<S, Presentation> mapping, {
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

  // Check if new mapping is a Router
  final presentation = mapping[machine.activeStateId];
  if (presentation is PageCreator && presentation.widget is w.Builder) {
    final childMachine = _getChildMachine(machine);
    if (childMachine != null) {
      await checkMachine(
        tester: tester,
        act: act,
        machine: childMachine,
        mapping: childMachine.routerDelegate.mapping,
      );
    }
  } else {
    checkTitle(machine);
  }
}

StateMachineWithChangeNotifier<S, E, T>? _getChildMachine(
  StateMachineWithChangeNotifier<S, E, T> machine,
) {
  final state = machine.states[machine.activeStateId];
  if (state is State<E, T, S>) {
    return state.regions[0].machine as StateMachineWithChangeNotifier<S, E, T>;
  } else {
    return null;
  }
}
