import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import 'creator.dart';
import 'hisma_router_delegate_new.dart';

// Challenges:
//
// Imperative navigation interfering with paged (declarative navigation):
//    When jumping back a state mapped to a ImperativeCreator we might
//    already have one or more states on the stack mapped to PageCreators.
//    Handling this would require popping up imperatively the corresponding
//    paged routes.
//
//    Solution: Passing PageCreators is not allowed (assert).
//
// Principles
// A UI element shall ONLY be closed if a circle is formed in that state
// sequence path (sequence of stateIds that has been passed during building the
// UI).

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

  late HismaRouterDelegateNew<S, E> routerDelegate;

  @override
  Future<void> fire(
    E eventId, {
    BuildContext? context,
    dynamic arg,
    bool external = true,
  }) async {
    final originalStateId = activeStateId;
    final isOriginalInStack = routerDelegate.isInStack(originalStateId);
    await super.fire(eventId, arg: arg, external: external);
    assert(
      isOriginalInStack || routerDelegate.isInStack(activeStateId),
      'Imperative ui was closed but the event defined in its creator led to '
      'a state that is not present in the stack (the path is not forming a '
      'circle). Check your mapping in your corresponding HismaRouterGenerator.',
    );
    if (!external) return; // Why?
    if (originalStateId == activeStateId) {
      return; // No state change -> No UI change.
    }

    if (routerDelegate.isInStack(activeStateId)) {
      notifyListeners();
    } else {
      final presentation = routerDelegate.mapping[activeStateId];
      if (presentation is ImperativeCreator) {
      } else if (presentation is PageCreator) {
        notifyListeners();
      } else {
        throw ArgumentError('Unhandled presentation type $presentation');
      }
    }
  }

  Future<void> fire2(
    E eventId, {
    BuildContext? context,
    dynamic arg,
    bool external = true,
  }) async {
    final before = activeStateId;
    await super.fire(eventId, arg: arg, external: external);
    if (!external) return; // Why?
    if (before == activeStateId) return; // No state change -> No UI change.

    // These are only to allow type propagation.
    final id = activeStateId;
    assert(id != null);
    if (id != null) {
      if (routerDelegate.isCircle()) {
        routerDelegate.windBack(id, (S stateId) {
          final p = routerDelegate.mapping[stateId];
          assert(p is ImperativeCreator);
          if (p is ImperativeCreator) p.close();
        });
      }

      final presentation = routerDelegate.mapping[id];

      if (presentation is ImperativeCreator<E, dynamic>) {
        assert(!routerDelegate.intermediatePageCreator(id));
        print('ImperativeCreator');
        routerDelegate.addState(id);
        final before = activeStateId;
        final dynamic result = await presentation
            .open(context ?? routerDelegate.navigatorKey.currentContext);

        print('activeStateId: $activeStateId');
        if (activeStateId == before) {
          final event = presentation.event;
          if (event != null) {
            // We only want here to update the machine, since the UI has been
            // already updated - we arrive here when the corresponding
            // imperatively created UI was closed.
            await super.fire(event, arg: result, external: external);
            assert(
              routerDelegate.isCircle(),
              'activeStateId $activeStateId is NOT closing a circle. '
              'When we got here the imperatively created ui was already closed '
              'implying that we are going backwards on the list of states that '
              'created UIs before. If we detect that the new state where we go '
              'from here is not in this list we fail this assertion.',
            );
          }
        }
      } else {
        notifyListeners();
      }
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

class OldCtxArg {
  OldCtxArg(this.context, [this.arg]);
  BuildContext context;
  dynamic arg;
}
