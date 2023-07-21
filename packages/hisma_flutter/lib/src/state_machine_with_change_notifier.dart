import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import 'hisma_pageless_handler.dart';

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

  HismaPagelessHandler<S, E>? pagelessHandler;

  BuildContext? _context;

  @override
  Future<void> fire(
    E eventId, {
    dynamic arg,
    BuildContext? context,
    bool external = true,
  }) async {
    // If fire comes from UI it will include the context and we will set
    // save the context until the completion of this operation when we set it
    // to null.
    // TODO: What if there is a independent fire in-between? What if it comes
    // from the UI with context?
    _context = context ?? _context;
    await super.fire(eventId, arg: arg, external: external);

    // These are only to ally type propagation.
    final ctx = _context;
    final id = activeStateId;
    final handler = pagelessHandler;

    if (handler != null &&
        id != null &&
        handler.isPageless(id) &&
        ctx != null) {
      unawaited(
        handler.openPageless(
          stateId: id,
          context: ctx,
        ),
      );
    } else {
      notifyListeners();
    }
    _context = null;
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
  // @override
  // Future<void> stop({required dynamic arg}) async {
  //   // TODO: Why required arg?
  //   await super.stop(arg: arg);
  //   // notifyListeners();
  // }

  @override
  StateMachineWithChangeNotifier<S1, E1, T1> find<S1, E1, T1>(String name) {
    final machine = super.find<S1, E1, T1>(name);
    if (machine is! StateMachineWithChangeNotifier<S1, E1, T1>) {
      throw Exception('Machine $name is ${machine.runtimeType}.');
    }
    return machine;
  }
}
