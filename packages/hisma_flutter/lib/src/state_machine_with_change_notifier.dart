import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import '../hisma_flutter.dart';
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
  HismaRouterDelegateNew<S, E>? routerDelegate;

  @override
  Future<void> fire(
    E eventId, {
    dynamic arg,
    bool external = true,
  }) async {
    await super.fire(eventId, arg: arg, external: external);
    if (!external) return;

    final context = arg is BuildContext
        ? arg
        : arg is CtxArg
            ? arg.context
            : null;

    print('CONTEXT: $context, ${context.hashCode}');

    // These are only to allow type propagation.
    final handler = pagelessHandler;
    final id = activeStateId;

    if (handler != null && id != null && handler.isPageless(id)) {
      assert(context != null, 'BuildContext was not parsed in arg: arg=$arg');
    }

    if (handler != null &&
        id != null &&
        handler.isPageless(id) &&
        context != null) {
      unawaited(
        handler.openPageless(
          stateId: id,
          context: context,
        ),
      );
      // print('fire: Starting waiting...');
      // await Future.delayed(const Duration(seconds: 6), () {
      //   print('fire: DONE waiting.');
      // });
      // print('fire: Done.');
    } else {
      notifyListeners();
    }
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

class CtxArg {
  CtxArg(this.context, [this.arg]);
  BuildContext context;
  dynamic arg;
}
