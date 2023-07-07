import 'package:flutter/foundation.dart';
import 'package:hisma/hisma.dart';

class StateMachineWithChangeNotifier<S, E, T> extends StateMachine<S, E, T>
    with ChangeNotifier {
  StateMachineWithChangeNotifier({
    super.events = const [],
    required super.name,
    super.history,
    required super.initialStateId,
    required super.states,
    required super.transitions,
  });

  factory StateMachineWithChangeNotifier.fromStateMachine(
    StateMachine<S, E, T> sm,
  ) =>
      StateMachineWithChangeNotifier(
        events: sm.events,
        name: sm.name,
        history: sm.history,
        initialStateId: sm.initialStateId,
        states: sm.states,
        transitions: sm.transitions,
      );

  @override
  Future<void> fire(E eventId, {dynamic arg, bool external = true}) async {
    await super.fire(eventId, arg: arg, external: external);
    notifyListeners();
  }

  @override
  Future<void> start({
    S? entryPointId,
    dynamic arg,
    bool historyFlowDown = false,
  }) async {
    await super.start(
      entryPointId: entryPointId,
      arg: arg,
      historyFlowDown: historyFlowDown,
    );
    notifyListeners();
  }

  // We shall NOT send notification in case of stop as RouterDelegate would
  // try building Navigator.pages and that is not needed as pages shall remain
  // to allow transition from old to new state.
  //
  @override
  Future<void> stop({required dynamic arg}) async {
    // TODO: Why required arg?
    await super.stop(arg: arg);
    notifyListeners();
  }

  @override
  StateMachineWithChangeNotifier<S1, E1, T1> find<S1, E1, T1>(String name) {
    final machine = super.find<S1, E1, T1>(name);
    if (machine is! StateMachineWithChangeNotifier<S1, E1, T1>) {
      throw Exception('Machine $name is ${machine.runtimeType}.');
    }
    return machine;
  }
}
