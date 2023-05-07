import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'assistance.dart';
import 'creator.dart';
import 'state_machine_with_change_notifier.dart';

typedef PageMap<S> = Map<S, Page<dynamic>>;

class HismaRouterDelegatePop<S, W, E> extends RouterDelegate<S>
    with ChangeNotifier {
  HismaRouterDelegatePop(this._machine, this._mapping) {
    _machine.addListener(notifyListeners);
    // _navigatorKey =
    //     GlobalKey<NavigatorState>(debugLabel: 'Machine: ${_machine.name}');
  }

  final _log = getLogger('$HismaRouterDelegatePop');

  final StateMachineWithChangeNotifier<S, E, dynamic> _machine;
  final Map<S, Presentation> _mapping;
  final PageMap<S> _pageMap = {};

  @override
  Widget build(BuildContext context) {
    _log.info('machine: ${_machine.name}, state: ${_machine.activeStateId}');

    final state = _machine.activeStateId;
    if (state != null) {
      if (!_removeCircleWithPageless(state)) {
        _processState(state);
      }
    }
    _log.fine('pages: $_pageMap');
    print('@@@ pages: $_pageMap');
    return _getNavigator();
  }

  @override
  Future<bool> popRoute() {
    // TODO: We shall allow exit from the app here by returning false.
    // TODO: Instead check for Creator<E> and doe one fire.
    _log.info('popRoute');

    final creator = _mapping[_machine.activeStateId];
    if (creator is Creator<E> &&
        // creator.overlay &&
        creator.event != null) {
      Future.delayed(
        Duration.zero,
        () async {
          _log.info('firing1');
          await _machine.fire(creator.event as E);
        },
      );
    } else {
      _log.info('nothing to do');
    }

    return SynchronousFuture<bool>(true);
  }

  @override
  Future<void> setNewRoutePath(S configuration) async {
    // TODO: implement setNewRoutePath
  }

  void _processState(S state) {
    final creator = _mapping[state];
    if (creator == null) throw ArgumentError('$state : ${_machine.name}');

    if (creator is PageCreator<W, S, E> && !creator.overlay) {
      // _popPageless();
      // _cleanPages();
      _pageMap.clear();
      _pageMap[state] = creator.create(
        state: state,
        widget: creator.widget,
      );
    } else {
      if (creator is PageCreator<W, S, E> && creator.overlay) {
        _pageMap[state] = creator.create(
          state: state,
          widget: creator.widget,
        );
      } else if (creator is PagelessCreator<dynamic, E>) {
        _addPageless(state, creator);
      } else if (creator is NoUIChange) {
        // No update
      } else {
        throw ArgumentError('Missing $state : ${creator.runtimeType}');
      }
    }
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Widget _getNavigator() {
    return Navigator(
      key: _navigatorKey,
      pages: _pageMap.values
          .where((page) => page is! PagelessPage<void, S>)
          .toList(),
      onPopPage: (route, dynamic result) {
        _log.info('Navigator.onPopPage($route, $result)');
        _log.info('${route.settings.name}');
        _log.info('machine: ${_machine.name} - ${_machine.activeStateId}');
        final creator = _mapping[_machine.activeStateId];
        if (creator is PageCreator<W, S, E> && creator.overlay) {
          final event = creator.event;
          if (event != null) {
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

  bool _removeCircleWithPageless(S state) {
    if (_pageMap.keys.contains(state)) {
      // _popPageless(state);
      // _removePages(state);
      _rmPages2(state);
      return true;
    }
    return false;
  }

  void _rmPages2([S? from]) {
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

  // void _rmPages([S? from]) {
  //   var found = false;
  //   var pageRemoved = false;
  //   for (final entry in _pageMap.entries) {
  //     if (!found && entry.key != from) continue;
  //     found = true;
  //     final page = entry.value;
  //     if (!pageRemoved && page is PagelessPage<void, S>) {
  //       Future.delayed(Duration.zero, () {
  //         final creator = _mapping[entry.key];
  //         if (creator is! PagelessCreator<dynamic, E>) {
  //           throw AssertionError('creator is $creator');
  //         }

  //         // if (!creator.pagelessRouteManager.closed) {
  //         creator.close();
  //         // }
  //       });
  //     } else {
  //       pageRemoved = true;
  //     }

  //     _pageMap.remove(entry.key);
  //   }
  // }

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

  // void _removePages([S? state]) {
  //   while (_pageMap.isNotEmpty && _pageMap.entries.last.key != state) {
  //     final entry = _pageMap.entries.last;
  //     _pageMap.remove(entry.key);
  //   }
  // }

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
