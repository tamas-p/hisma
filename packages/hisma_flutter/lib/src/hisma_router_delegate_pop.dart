import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'assistance.dart';
import 'creator.dart';
import 'state_machine_with_change_notifier.dart';

typedef PageMap<S> = Map<S, Page<dynamic>>;

class HismaRouterDelegatePop<S, E> extends RouterDelegate<S>
    with ChangeNotifier {
  HismaRouterDelegatePop(this._machine, this._mapping) {
    // Machine changes will result notifying listeners of this router delegate.
    _machine.addListener(notifyListeners);
  }

  final _log = getLogger('$HismaRouterDelegatePop');

  /// Machine that this router delegate represents.
  final StateMachineWithChangeNotifier<S, E, dynamic> _machine;

  /// Mapping machine states to a presentation. It is defined in
  /// HismaRouterGenerator constructor.
  final Map<S, Presentation> _mapping;

  /// Page map that will be used as the input for Navigator.pages.
  final PageMap<S> _pageMap = {};

  @override
  Widget build(BuildContext context) {
    _log.fine('>>>>>>>>>>>>>> BUILD START >>>>>>>>>>>>>>>>>');
    _log.info(
      () => 'machine: ${_machine.name}, state: ${_machine.activeStateId}',
    );

    final activeStateId = _machine.activeStateId;
    final sameAsBefore =
        _pageMap.keys.isNotEmpty && activeStateId == _pageMap.keys.last;
    // There are two prerequisites to process based on activeStateId:
    // (1) We only process if machine is active. If inactive we simply build
    //     pages of the navigator from the current _pageMap (that was updated
    //     in previous builds). This is required to handle the case when a child
    //     machine gets inactivated but we need its previous presentation to
    //     allow the transition to the new page.
    // (2) activeStateId shall not be the last key in the page map. Being
    //     notified when activeStateId is not different compared to last time
    //     we updated the page map means that no update on the page map is
    //     needed.
    if (activeStateId != null && !sameAsBefore) {
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

    _log.fine(() => 'pages: $_pageMap');
    _log.fine(
      () => '@@@ machine: ${_machine.name} '
          'state: ${_machine.activeStateId} _pageMap: $_pageMap',
    );
    final pages = _buildNavigator(sameAsBefore);
    _log.fine('<<<<<<<<<<<<<<<<<<< BUILD DONE <<<<<<<<<<<<<<<<<<<<<<<<<<');
    return pages;
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
    if (presentation is PageCreator<dynamic, S, E>) {
      if (presentation.overlay == false) _pageMap.clear();
      _pageMap[stateId] = presentation.create(
          name: '${_machine.name}-$stateId', widget: presentation.widget);
    } else if (presentation is PagelessCreator<dynamic, E>) {
      _pageMap[stateId] = PagelessPage<S>(
        name: '${_machine.name}-$stateId',
        creator: presentation,
      );
    } else if (presentation is NoUIChange) {
      // Explicit no update was requested, so we do nothing.
    } else {
      throw ArgumentError(
        'Presentation ${presentation.runtimeType} is not handled for $stateId.'
        ' Check mapping in your HismaRouterGenerator for machine ${_machine.name}',
      );
    }
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Builds Navigator from _pageMap.
  Widget _buildNavigator(bool sameAsBefore) {
    return Navigator(
      // Navigator key must belong to the router delegate object to allow
      // transitions working properly as Flutter will be able to identify if
      // the passed Navigator is for the same purpose as the previous one was
      // passed by the router delegate.
      key: _navigatorKey,
      // Processing and filtering out all pages that represent pageless routes.
      pages: _processPageless(sameAsBefore),
      onPopPage: (route, dynamic result) {
        // When using hisma_flutter exclusively to manage routing this callback
        // shall be only invoked when user presses the framework generated
        // back button in an AppBar which is only happens when the page is an
        // PageCreator where overlay attribute is true.
        _log.info('Navigator.onPopPage($route, $result)');
        _log.info('${route.settings.name}');
        _log.info('machine: ${_machine.name} - ${_machine.activeStateId}');
        final creator = _mapping[_machine.activeStateId];
        if (creator is PageCreator<dynamic, S, E> && creator.overlay) {
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

  List<Page<dynamic>> _processPageless(bool sameAsBefore) {
    // ignore: prefer_collection_literals
    final pm = PageMap<S>();

    final toClose = <PagelessCreatorWithId<S, E>>[];
    final toOpen = <PagelessCreatorWithId<S, E>>[];

    _pageMap.forEach((stateId, page) {
      if (page is PagelessPage<S>) {
        final creator = page.creator as PagelessCreator<dynamic, E>;
        _log.fine(
          () => 'Mounted: ${_machine.name}-$stateId = ${page.creator.mounted}',
        );
        if (stateId == _machine.activeStateId) {
          if (!sameAsBefore || !creator.mounted) {
            toOpen.add(PagelessCreatorWithId<S, E>(stateId, creator));
          }
        } else if (_machine.activeStateId != null) {
          toClose.add(PagelessCreatorWithId<S, E>(stateId, creator));
        }
      } else {
        pm[stateId] = page;
      }
    });

    for (final creatorWithId in toClose) {
      // We need to close in this build cycle, not using Future
      // to avoid closing the next page that was added in this
      // build cycle.
      creatorWithId.creator.close();
    }

    _addPageless(toOpen, pm);
    return pm.values.where((page) => page is! PagelessPage).toList();
  }

  // TODO: refactor
  void _cleanUpCircle([S? from]) {
    var found = false;
    var pageRemoved = false;

    _pageMap.removeWhere((stateId, page) {
      if (!found && stateId != from) return false;
      found = true;
      if (stateId == from) return false;
      if (!pageRemoved && page is PagelessPage<S>) {
        final creator = _mapping[stateId];
        if (creator is! PagelessCreator<dynamic, E>) {
          throw AssertionError('creator is $creator');
        }
        creator.close();
      } else {
        pageRemoved = true;
      }
      return true;
    });
  }

  void _addPageless(
    List<PagelessCreatorWithId<S, E>> toOpen,
    PageMap<S> pageMap,
  ) {
    final machineName = _machine.name;
    final lastPageCreatorWithId = _getLastPageCreator();
    final lastPageWithPageless = lastPageCreatorWithId.creator.create(
      name: '${_machine.name}-${lastPageCreatorWithId.stateId}',
      widget: Builder(
        builder: (context) {
          /// We schedule execution of pagelessCreator.open for next cycle.
          Future.delayed(Duration.zero, () async {
            for (final creatorWithId in toOpen) {
              final pagelessStateId = creatorWithId.stateId;
              final pagelessCreator = creatorWithId.creator;

              _log.finest(
                () =>
                    '_addPageless: ${_machine.activeStateId}, $pagelessStateId',
              );
              if (_machine.activeStateId == pagelessStateId) {
                _log.finest(
                  () => '_addPageless: adding page for ${_machine.name},'
                      '$machineName - ${_machine.activeStateId}',
                );
                final dynamic result = await pagelessCreator.open(context);
                _log.finest(
                  () =>
                      '_addPageless: COMPLETED ${_machine.name},$machineName -'
                      ' $pagelessStateId',
                );
                _log.info(() => 'pagelessCreator.open result is $result.');
                _pageMap.remove(pagelessStateId);
                // Only fire if we are still in the state we were created.
                // It avoids unwanted fire() in case we got here by a fire().
                final event = pagelessCreator.event;
                if (event != null &&
                    _machine.activeStateId == pagelessStateId) {
                  await _machine.fire(event, arg: result);
                }
              }
            }
          });

          return lastPageCreatorWithId.creator.widget;
        },
      ),
    );

    pageMap[lastPageCreatorWithId.stateId] = lastPageWithPageless;
  }

  LastPageCreatorWithId<S, E> _getLastPageCreator([S? pagelessStateId]) {
    if (_pageMap.isEmpty) {
      throw ArgumentError('Empty _pageMap.'
          ' Pageless routes can only be added on top of a paged route.');
    }

    S? lastPageStateId;
    for (final e in _pageMap.entries) {
      final stateId = e.key;
      final page = e.value;

      if (page is PagelessPage) {
        if (stateId == pagelessStateId) break;
      } else {
        lastPageStateId = stateId;
      }
    }

    if (lastPageStateId == null) {
      throw ArgumentError('lastP is null.');
    }
    final lastPageCreator = _mapping[lastPageStateId];
    if (lastPageCreator == null) {
      throw ArgumentError('lastPageCreator is null.');
    }
    if (lastPageCreator is! PageCreator<dynamic, S, E>) {
      throw ArgumentError(
        'lastPageCreator is not PageCreator but $lastPageCreator',
      );
    }

    return LastPageCreatorWithId(lastPageStateId, lastPageCreator);
  }
}

class LastPageCreatorWithId<S, E> {
  LastPageCreatorWithId(this.stateId, this.creator);

  final S stateId;
  final PageCreator<dynamic, S, E> creator;
}

class PagelessCreatorWithId<S, E> {
  PagelessCreatorWithId(this.stateId, this.creator);

  final S stateId;
  final PagelessCreator<dynamic, E> creator;
}

class PagelessPage<S> extends Page<S> {
  PagelessPage({
    required String name,
    required this.creator,
  }) : super(key: ValueKey(name), name: name);

  // TODO: Add generics type.
  final PagelessCreator<dynamic, dynamic> creator;

  @override
  Route<S> createRoute(BuildContext context) {
    throw UnimplementedError();
  }
}
