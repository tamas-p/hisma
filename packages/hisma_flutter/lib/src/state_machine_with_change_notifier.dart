import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import 'hisma_router_delegate.dart';

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

  HismaRouterDelegate<S, E>? _delegate;
  // ignore: avoid_setters_without_getters
  set delegate(HismaRouterDelegate<S, E> delegate) {
    _delegate = delegate;
  }

  BuildContext? currentContext;

  @override
  Future<void> fire(
    E eventId, {
    dynamic arg,
    BuildContext? context,
    bool external = true,
  }) async {
    currentContext = context ?? currentContext;
    await super.fire(eventId, arg: arg, external: external);

    final ctx = currentContext;
    if (_delegate != null && activeStateId != null && ctx != null) {
      if (_delegate?.isPageless(activeStateId as S) ?? false) {
        unawaited(
          _delegate?.openPageless(
            stateId: activeStateId as S,
            context: ctx,
          ),
        );
      } else {
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
    currentContext = null;
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
