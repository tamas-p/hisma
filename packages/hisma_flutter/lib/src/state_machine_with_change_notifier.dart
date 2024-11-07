import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import 'assistance.dart';
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
    final navigatorState = context != null ? Navigator.of(context) : null;
    final originalStateId = activeStateId;
    final isOriginalInStack = routerDelegate.stack.contains(originalStateId);
    await super.fire(eventId, arg: arg, external: external);
    final newStateId = activeStateId;
    if (newStateId == null) return; // Machine stopped, no need to update UI.
    assert(
      isOriginalInStack || routerDelegate.stack.contains(activeStateId),
      'Imperative ui was closed but the event defined in its creator led to '
      'a state that is not present in the stack (the path is not forming a '
      'circle). Check your mapping in your corresponding HismaRouterGenerator.',
    );
    if (!external) {
      print('External.');
      return;
    } // Why?
    if (originalStateId == activeStateId) {
      print(
        'originalStateId: $originalStateId == activeStateId: $activeStateId',
      );
      return; // No state change -> No UI change.
    }

    final newPresentation = routerDelegate.mapping[newStateId];
    assert(newPresentation != null, assertPresentationMsg(newStateId, name));
    if (routerDelegate.stack.contains(newStateId)) {
      // Circle
      if (newPresentation is ImperativeCreator) {
        if (!routerDelegate.stack.isLast(newStateId)) {
          // Only if presentation was not already closed.
          if (routerDelegate.stack.rightBeforePage(newStateId)) {
            notifyListeners();
          } else {
            _windBack(newStateId, navigatorState);
          }
        }
      } else if (newPresentation is PageCreator) {
        if (routerDelegate.stack.hasImperatives(newStateId)) {
          _windBack(newStateId, navigatorState);
        } else {
          notifyListeners();
        }
      } else {
        throw ArgumentError('Unhandled presentation type $newPresentation');
      }
    } else {
      // New Presentation
      if (newPresentation is ImperativeCreator<E, dynamic>) {
        final oldStateId = activeStateId;
        routerDelegate.stack.add(newStateId);
        final dynamic result = await newPresentation.open(
          navigatorState?.context ?? routerDelegate.navigatorKey.currentContext,
        );
        routerDelegate.stack.remove(newStateId); // Signal that imp. was closed.
        final event = newPresentation.event;
        if (event != null && activeStateId == oldStateId) {
          await fire(event, arg: result, external: external);
        }
      } else if (newPresentation is PageCreator) {
        notifyListeners();
      } else {
        throw ArgumentError('Unhandled presentation type $newPresentation.');
      }
    }
  }

  void _windBack(S newStateId, NavigatorState? navigatorState) {
    routerDelegate.stack.windBack(newStateId, (stateId) {
      final presentation = routerDelegate.mapping[stateId];
      if (presentation is ImperativeCreator) {
        presentation.close();
      } else if (presentation is PageCreator) {
        final c = navigatorState?.context ??
            routerDelegate.navigatorKey.currentContext;
        assert(c != null);
        if (c != null) Navigator.of(c).pop();
      }
    });
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
      if (routerDelegate.stack.contains(activeStateId)) {
        routerDelegate.stack.windBack(id, (S stateId) {
          final p = routerDelegate.mapping[stateId];
          assert(p is ImperativeCreator);
          if (p is ImperativeCreator) p.close();
        });
      }

      final presentation = routerDelegate.mapping[id];

      if (presentation is ImperativeCreator<E, dynamic>) {
        assert(!routerDelegate.stack.intermediatePageCreator(id));
        print('ImperativeCreator');
        routerDelegate.stack.add(id);
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
              routerDelegate.stack.contains(activeStateId),
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
