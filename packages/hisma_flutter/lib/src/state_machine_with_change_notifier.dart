import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import 'assistance.dart';
import 'creator.dart';
import 'hisma_router_delegate.dart';

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

// TODO: find better name for this class.
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

  late HismaRouterDelegate<S, E> routerDelegate;

  @override
  Future<void> fire(
    E eventId, {
    BuildContext? context,
    dynamic arg,
    bool external = true,
  }) async {
    final navigatorState = context != null
        ? Navigator.of(context)
        : routerDelegate.navigatorKey.currentState;
    final originalStateId = activeStateId;
    final isOriginalStateIdInStack =
        routerDelegate.stack.contains(originalStateId);
    await super.fire(eventId, arg: arg, external: external);
    final newStateId = activeStateId;
    if (newStateId == null) {
      // Machine stopped, no need to update UI.
      // test: ? stopped_machine
      return;
    }
    final isNewStateIdInStack = routerDelegate.stack.contains(activeStateId);
    assert(
      // test: ?
      isOriginalStateIdInStack || isNewStateIdInStack,
      'UI element was closed but the event defined in its creator led to '
      'a state that is not present in the stack (the path is not forming a '
      'circle). Check your mapping in your corresponding HismaRouterGenerator.',
    );
    if (!external) {
      // Why? test: ? external_fire
      return;
    }
    if (originalStateId == activeStateId) {
      // No change -> No UI change.
      // test: no_state_change
      return;
    }

    final newPres = routerDelegate.mapping[newStateId];
    // test: missing_presentation ?
    assert(newPres != null, missingPresentationMsg(newStateId, name));
    if (newPres is NoUIChange) {
      // test: no_ui_change
      routerDelegate.stack.add(newStateId);
      return;
    }
    assert(newPres is PageCreator || newPres is ImperativeCreator);
    if (isNewStateIdInStack) {
      // Circle
      if (newPres is ImperativeCreator) {
        if (!routerDelegate.stack.isLast(newStateId)) {
          // Only if presentation was not already closed.
          if (routerDelegate.stack.rightBeforePage(newStateId)) {
            // test: circle_to_imperative_before_page
            notifyListeners();
          } else {
            // test: circle_to_imperative
            _windBack(newStateId, navigatorState);
          }
        }
      } else if (newPres is PageCreator) {
        if (routerDelegate.stack.hasImperatives(newStateId)) {
          // test: circle_to_page_has_imperatives
          _windBack(newStateId, navigatorState);
        } else {
          // test: circle_to_page_has_no_imperatives
          notifyListeners();
        }
      }
    } else {
      // New Presentation
      if (newPres is ImperativeCreator<E, dynamic>) {
        // test: new_presentation_imperative_open
        final oldStateId = activeStateId;
        routerDelegate.stack.add(newStateId);

        // We want open to be executed async to the fire.
        unawaited(
          newPres.open(navigatorState?.context).then((dynamic result) {
            // test: imperative_closed
            // Signal that imp. was closed shall be removed.
            routerDelegate.stack.remove(newStateId);
            final event = newPres.event;
            // TODO: Instead of assert event could be required.
            assert(
              event != null,
              'For imperative creator $newPres event shall not be null.',
            );
            if (event != null && activeStateId == oldStateId) {
              fire(event, arg: result, external: external);
            }
          }),
        );
      } else if (newPres is PageCreator) {
        // test: new_presentation_page_notify
        // test: new_presentation_page_notify_overlay
        notifyListeners();
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
      // TODO: isn't it simpler/better simply return null?
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
