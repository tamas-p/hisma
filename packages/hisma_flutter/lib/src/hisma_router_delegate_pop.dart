import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'assistance.dart';
import 'creator.dart';
import 'state_machine_with_change_notifier.dart';

class HismaRouterDelegatePop<S, W, E> extends RouterDelegate<S>
    with ChangeNotifier {
  HismaRouterDelegatePop(this._machine, this._mapping) {
    // Machine changes will result notifying listeners of this router delegate.
    _machine.addListener(notifyListeners);
  }

  final _log = getLogger('$HismaRouterDelegatePop');

  /// Machine that this router delegate represents.
  final StateMachineWithChangeNotifier<S, E, dynamic> _machine;

  /// Mapping machine states to a presentation.
  final Map<S, Presentation> _mapping;

  /// Page map that will be used as the input for Navigator.pages.
  final Map<S, Page<dynamic>> _pageMap = {};

  @override
  Widget build(BuildContext context) {
    _log.info('machine: ${_machine.name}, state: ${_machine.activeStateId}');

    final activeStateId = _machine.activeStateId;
    // We only process if machine is active. If inactive we simply build
    // pages of the navigator from the current _pageMap (that was updated
    // in previous builds). This is required to handle the case when a child
    // machine gets inactivated but we need its previous presentation to allow
    // the transition to the new page.
    if (activeStateId != null) {
      // We only process the state if it is not leading us back to a previous
      // state in a circle that current _pageMap (hence current navigator pages)
      // includes.

      if (_pageMap.keys.contains(activeStateId)) {
        // Since we arrived back to a state that (more precisely the page
        // created by its Presentation) is already in the current
        // Navigator.pages (through the circle in the state transition graph),
        // we have to clean up the pages on the circle.
        _cleanUpCircle(activeStateId);
      } else {
        // This state (more precisely the page created by its Presentation) is
        // not represented in Navigator.pages hence we need to add it.
        _addState(activeStateId);
      }
    }
    _log.fine('pages: $_pageMap');
    print('@@@ pages: $_pageMap');
    return _getNavigator();
  }

  /// Handles the back button request from the operating system.
  /// Having and event defined for the corresponding Creator it will
  /// be fired on the machine. It is always returns true avoiding the
  /// popping of the entire application.
  @override
  Future<bool> popRoute() {
    _log.info('popRoute');

    final creator = _mapping[_machine.activeStateId];
    if (creator is Creator<E> && creator.event != null) {
      Future.delayed(
        Duration.zero,
        () async {
          _log.info(
            'popRoute: Firing ${creator.event} on machine ${_machine.name}.',
          );
          await _machine.fire(creator.event as E);
        },
      );
    } else {
      _log.info('popRoute: Nothing to do for $creator.');
    }

    return SynchronousFuture<bool>(true);
  }

  @override
  Future<void> setNewRoutePath(S configuration) async {
    // TODO: implement setNewRoutePath
  }

  void _addState(S stateId) {
    final presentation = _mapping[stateId];
    if (presentation == null) {
      throw ArgumentError(
        'No presentation is defined for $stateId : ${_machine.name}',
      );
    }

    if (presentation is PageCreator<W, S, E> && !presentation.overlay) {
      _pageMap.clear();
      _pageMap[stateId] =
          presentation.create(state: stateId, widget: presentation.widget);
    } else {
      if (presentation is PageCreator<W, S, E> && presentation.overlay) {
        _pageMap[stateId] = presentation.create(
          state: stateId,
          widget: presentation.widget,
        );
      } else if (presentation is PagelessCreator<dynamic, E>) {
        _addPageless(stateId, presentation);
      } else if (presentation is NoUIChange) {
        // No update
      } else {
        throw ArgumentError('Missing $stateId : ${presentation.runtimeType}');
      }
    }
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Widget _getNavigator() {
    return Navigator(
      // Navigator key must belong to the router delegate object to allow
      // transitions working properly as Flutter will be able to identify if
      // the passed Navigator is for the same purpose as the previous one was
      // passed by the router delegate.
      key: _navigatorKey,
      pages: _pageMap.values
          .where((page) => page is! PagelessPage<void, S>)
          .toList(),
      onPopPage: (route, dynamic result) {
        // When using hisma_flutter exclusively to manage routing this callback
        // shall be only invoked when user presses the framework generated
        // back button in an AppBar which is only happens when the page is an
        // PageCreator where overlay attribute is true.
        _log.info('Navigator.onPopPage($route, $result)');
        _log.info('${route.settings.name}');
        _log.info('machine: ${_machine.name} - ${_machine.activeStateId}');
        final creator = _mapping[_machine.activeStateId];
        if (creator is PageCreator<W, S, E> && creator.overlay) {
          final event = creator.event;
          if (event != null) {
            // We shall fire the event that was registered when the
            Future.delayed(Duration.zero, () {
              _machine.fire(event, arg: result);
            });
          }
        } else {
          throw AssertionError(
            'It must be here an PageCreator with overlay=true,'
            ' but it was $creator',
          );
        }

        if (route.didPop(result)) return true;
        return false;
      },
    );
  }

  void _cleanUpCircle([S? from]) {
    var found = false;
    var pageRemoved = false;

    _pageMap.removeWhere((state, page) {
      if (!found && state != from) return false;
      found = true;
      if (state == from) return false;
      if (!pageRemoved && page is PagelessPage<void, S>) {
        Future.delayed(Duration.zero, () {
          final creator = _mapping[state];
          if (creator is! PagelessCreator<dynamic, E>) {
            throw AssertionError('creator is $creator');
          }
          // if (!creator.pagelessRouteManager.closed) {
          creator.close();
          // }
        });
      } else {
        pageRemoved = true;
      }

      return true;
    });
  }

  void _cleanPages() {
    while (_pageMap.isNotEmpty) {
      final entry = _pageMap.entries.last;
      final key = entry.key;
      final page = entry.value;
      if (page is PagelessPage<void, S>) {
        final creator = _mapping[key];
        if (creator is! PagelessCreator<dynamic, E>) {
          throw AssertionError('creator is $creator');
        }
        Future.delayed(Duration.zero, () {
          creator.close();
        });
      }
      _pageMap.remove(key);
    }
  }

  void _popPageless([S? state]) {
    while (_pageMap.isNotEmpty && _pageMap.entries.last.key != state) {
      final entry = _pageMap.entries.last;
      final page = entry.value;
      if (page is! PagelessPage<void, S>) break;
      // We must pop pageless routes after Navigator.pages update
      // already happened to avoid popping a paged route here that is
      // "popped" implicitly by the Navigator.
      // That is said, but there will be a side effect seeing the
      // flashing the pageless routes for a fraction of a second.
      Future.delayed(Duration.zero, () {
        final creator = _mapping[entry.key];
        if (creator is! PagelessCreator<dynamic, E>) {
          throw AssertionError('creator is $creator');
        }

        // if (!creator.pagelessRouteManager.closed) {
        creator.close();
        // }
      });
      _pageMap.remove(entry.key);
    }
  }

  Page<W> _createPageWithFunction(
    S lastPageState,
    PageCreator<W, S, E> lastPageCreator,
    PagelessCreator<dynamic, E> pagelessCreator,
    PagelessPage<void, S> pagelessPage,
    S state,
  ) {
    return lastPageCreator.create(
      state: state,
      widget: Builder(
        builder: (context) {
          /// We schedule execution of function 'f' during next build cycle.
          Future.delayed(Duration.zero, () async {
            if (_machine.activeStateId == state &&
                !_pageMap.containsKey(state)) {
              _pageMap[state] = pagelessPage;
              final dynamic result = await pagelessCreator.open(context);
              _log.info(() => 'RESULT is $result');
              _pageMap.remove(state);
              // Only fire if we are still in the state we were created.
              // It avoids unwanted fire() in case we got here by a fire().
              final event = pagelessCreator.event;
              if (event != null && _machine.activeStateId == state) {
                await _machine.fire(event, arg: result);
              }
            }
          });

          return lastPageCreator.widget;
        },
      ),
    );
  }

  void _addPageless(
    S state,
    PagelessCreator<dynamic, E> creator,
  ) {
    if (_pageMap.isEmpty) throw ArgumentError('Empty _pageMap');
    final lastPageState = _pageMap.entries
        .where((entry) => entry.value is! PagelessPage<void, S>)
        .last
        .key;
    final lastPageCreator = _mapping[lastPageState];
    if (lastPageCreator == null) throw ArgumentError('oldCreator is null.');
    if (lastPageCreator is! PageCreator<W, S, E>) throw ArgumentError();
    final pagelessPage = PagelessPage<void, S>();
    final newPage = _createPageWithFunction(
      lastPageState,
      lastPageCreator,
      creator,
      pagelessPage,
      state,
    );
    _pageMap[lastPageState] = newPage;
  }
}

class PagelessPage<T, S> extends Page<T> {
  @override
  Route<T> createRoute(BuildContext context) {
    throw UnimplementedError();
  }
}
