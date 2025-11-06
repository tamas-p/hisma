import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisma/hisma.dart';

import 'assistance.dart';
import 'creator.dart';
import 'hisma_router_delegate.dart';

/// State machine managing navigation
class NavigationMachine<S, E, T> extends Machine<S, E, T> with ChangeNotifier {
  NavigationMachine({
    required super.name,
    required super.initialStateId,
    required super.states,
    required super.transitions,
    super.events = const [],
    // history is disabled for now. It's usefulness is to be justified in
    // navigation context then need to be prototyped. Also see assert in
    // HismaRouterDelegate constructor.
    // super.history,
    super.data,
    super.strict,
  });

  late HismaRouterDelegate<S, E> _routerDelegate;
  bool _initialized = false;
  // ignore: avoid_setters_without_getters
  set routerDelegate(HismaRouterDelegate<S, E> rd) {
    _routerDelegate = rd;
    _initialized = true;
  }

  void _windBack(S newStateId, NavigatorState? navigatorState) {
    _routerDelegate.stack.windBackTo(getKey(name, newStateId), (presentation) {
      if (presentation is ImperativeCreator) {
        presentation.close();
      } else if (presentation is PageCreator) {
        final c = navigatorState?.context ??
            _routerDelegate.navigatorKey.currentContext;
        assert(c != null);
        if (c != null) Navigator.of(c).pop();
      }
    });
  }

  @override
  Future<void> fire(
    E eventId, {
    BuildContext? context,
    dynamic arg,
  }) async {
    // We get the navigator state from the context before async gap (fire).
    final ns = context != null ? Navigator.of(context) : null;
    final originalStateId = activeStateId;
    await super.fire(
      eventId,
      arg: arg is UiClosed ? arg.arg : arg,
    );
    final newStateId = activeStateId;
    if (newStateId == null || !_initialized) {
      // If machine is stopped or _routerDelegate is not initialized we simply
      // return here as there is no need / not possible to update UI.
      // test: stopped_machine
      return;
    }
    final isNewStateIdInStack =
        _routerDelegate.stack.contains(getKey(name, activeStateId));
    assert(
      // test: assert_on_no_circle
      arg is! UiClosed || isNewStateIdInStack,
      'UI element was closed but the event defined in its creator led to '
      'a state that is not present in the stack (the path is not forming a '
      'circle). Check your mapping in your corresponding HismaRouterGenerator.',
    );
    if (originalStateId == activeStateId) {
      // No change -> No UI change.
      // test: no_state_change
      return;
    }

    final newPres = _routerDelegate.mapping[newStateId];
    // test: missing_presentation
    assert(newPres != null, missingPresentationMsg(newStateId, name));
    if (newPres is NoUIChange) {
      // test: no_ui_change
      _routerDelegate.stack.add(getKey(name, newStateId), newPres);
      return;
    }
    assert(newPres is PageCreator || newPres is ImperativeCreator);
    final navigatorState = ns ?? _routerDelegate.navigatorKey.currentState;
    if (isNewStateIdInStack) {
      // Circle
      if (newPres is ImperativeCreator) {
        if (!_routerDelegate.stack.isLast(getKey(name, newStateId))) {
          // Only if presentation was not already closed.
          // test: circle_to_imperative
        }
        _windBack(newStateId, navigatorState);
      } else if (newPres is PageCreator) {
        if (_routerDelegate.stack.hasImperatives(getKey(name, newStateId))) {
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
        _routerDelegate.stack.add(getKey(name, newStateId), newPres);
        final newIsImperativeInRoot =
            newPres is PagelessCreator<E, dynamic> && newPres.rootNavigator;
        if (newIsImperativeInRoot) {
          var p = parent as NavigationMachine<dynamic, dynamic, dynamic>?;
          while (p != null) {
            p._routerDelegate.stack.add(getKey(name, newStateId), newPres);
            p = p.parent as NavigationMachine<dynamic, dynamic, dynamic>?;
          }
        }

        // We want open to be executed async to the fire.
        unawaited(
          newPres
              .open(context ?? navigatorState?.context, arg)
              .then((dynamic result) {
            // test: imperative_closed
            // Signal that imp. was closed shall be removed.
            _routerDelegate.stack.remove(getKey(name, newStateId));
            if (newIsImperativeInRoot) {
              var p = parent as NavigationMachine<dynamic, dynamic, dynamic>?;
              while (p != null) {
                p._routerDelegate.stack.remove(getKey(name, newStateId));
                p = p.parent as NavigationMachine<dynamic, dynamic, dynamic>?;
              }
            }

            final event = newPres.event;
            assert(
              event != null,
              'For imperative creator $newPres event shall not be null.',
            );
            if (event != null && activeStateId == oldStateId) {
              fire(event, arg: UiClosed(result));
            }
          }),
        );
      } else if (newPres is PageCreator) {
        // If we arrive to (non-overlay) page we have to clean up pageless
        // in case they are on the root navigator and the new page is not.
        // Not sure how realistic scenario is this, since normally you would
        // have one such page in the beginning of a path and you only return
        // there (a circle) and then windup would happen as handling circle.
        if (!newPres.overlay && parent != null) {
          _routerDelegate.stack.windBackAll((_, presentation) {
            if (presentation is PagelessCreator && presentation.rootNavigator) {
              // test: page_in_path
              presentation.close();
            }
          });
        }

        // test: new_presentation_page_notify
        // test: new_presentation_page_notify_overlay
        notifyListeners();
      }
    }
  }

  @override
  Future<void> start({
    S? entryPointId,
    dynamic arg,
  }) async {
    await super.start(
      entryPointId: entryPointId,
      arg: arg,
    );

    notifyListeners();
  }

  // We shall NOT send notification in case of stop as RouterDelegate would
  // try building Navigator.pages and that is not needed as pages shall remain
  // to allow transition from old to new state.
  @override
  Future<void> stop({dynamic arg}) async {
    await super.stop(arg: arg);
    if (_initialized && parent != null) {
      _routerDelegate.stack.windBackAll((key, presentation) {
        if (presentation is PagelessCreator) {
          if (presentation.rootNavigator) {
            // We can safely close the dialog in the root navigator as we know
            // that this dialog must be on the top of the navigator stack.
            // test: restart_in_child_test_root_navigator
            presentation.close();
          } else {
            // We only need to set closed as the pageless will be removed by
            // the framework, but it does not complete its creator function
            // so we have to do it here explicitly.
            // test: leave_state_in_parent
            presentation.setClosed();
            _routerDelegate.stack.remove(key);
          }
        }
      });
    }
  }

  @override
  NavigationMachine<S1, E1, T1> find<S1, E1, T1>(String name) {
    final machine = super.find<S1, E1, T1>(name);
    if (machine is! NavigationMachine<S1, E1, T1>) {
      throw HismaMachineNotFoundException(
        'Machine $name is ${machine.runtimeType}.',
      );
    }
    return machine;
  }
}
