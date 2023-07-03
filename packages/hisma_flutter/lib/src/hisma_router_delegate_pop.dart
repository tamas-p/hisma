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

  /// List of state identifiers. It stores all state ids that are rendered to
  /// screen including pageless routes as well. It will be translated to a
  /// list of Pages using the creator (from _mapping) of the corresponding
  /// PageCreator for pages and might a pageless Route (from _pageless) by
  /// giving a Builder with a Future ti create the pageless route (see
  /// _addPageless). This approach - creating the pages during build and not
  /// storing the pages themselves - is required making sure that only the last
  /// page will include the Builder with Future for pageless routes as mentioned
  /// before.
  final List<S> _stateIds = [];

  /// There can be only one pageless route shown at a time in the application.
  static PagelessCreator<dynamic, dynamic>? _pageless;

  S? _previousStateId;

  @override
  Widget build(BuildContext context) {
    _log.fine('>>>>>>>>>>>>>> BUILD START >>>>>>>>>>>>>>>>>');
    _log.info(
      () => 'machine: ${_machine.name}, state: ${_machine.activeStateId}',
    );

    final activeStateId = _machine.activeStateId;
    final sameAsBefore = activeStateId == _previousStateId;
    _previousStateId = activeStateId;

    if (_pageless != null) {
      _pageless?.close();
      _pageless = null;
    }

    // There are two prerequisites to process based on activeStateId:
    // TODO: Review this text.
    // (1) We only process if machine is active. If inactive we simply build
    //     pages of the navigator from the current _pageMap (that was updated
    //     in previous builds). This is required to handle the case when a child
    //     machine gets inactivated but we need its previous presentation to
    //     allow the transition to the new page.
    // (2) activeStateId shall not be the last key in the page map. Being
    //     notified when activeStateId is not different compared to last time
    //     we updated the page map means that no update on the page map is
    //     needed.
    if (activeStateId != null) {
      // && !sameAsBefore) {
      // We only process the state if it is not leading us back to a previous
      // state in a circle that current _pageMap (hence current navigator pages)
      // includes.
      if (_stateIds.contains(activeStateId)) {
        // _closeLastPageless();
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

    final pages = _buildNavigator();
    _log.fine(
      () => '@@@ machine: ${_machine.name} '
          'state: ${_machine.activeStateId} _stateIds: $_stateIds '
          'page: $pages',
    );
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

  // NEED to add back PagelessPage to detect circles.

  void _addState(S stateId) {
    final presentation = _mapping[stateId];
    if (presentation is PageCreator<dynamic, S, E>) {
      if (presentation.overlay == false) _stateIds.clear();
      _stateIds.add(stateId);
    } else if (presentation is PagelessCreator<dynamic, E>) {
      _stateIds.add(stateId);
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
  Widget _buildNavigator() {
    return Navigator(
      // Navigator key must belong to the router delegate object to allow
      // transitions working properly as Flutter will be able to identify if
      // the passed Navigator is for the same purpose as the previous one was
      // passed by the router delegate.
      key: _navigatorKey,
      // Processing and filtering out all pages that represent pageless routes.
      pages: _processPageless(),
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

// pages.add(
//           presentation.create(
//             name: '${_machine.name}-$stateId',
//             widget: presentation.widget,
//           ),
//         );

  List<Page<dynamic>> _processPageless() {
    final pages = <Page<dynamic>>[];

    // OK to throw if empty - as it shall never be empty at this point.
    final lastId = _stateIds.last;

    // We only care about whether the last stateId in the stack is pageless or
    // not since our current implementation does not support overlay of pageless
    // routes, hence we only show a pageless route if it is the current (last).
    final lastPresentation = _mapping[lastId];
    Page<dynamic>? lastPage;
    if (lastPresentation is PagelessCreator<dynamic, E>) {
      lastPage = _addPageless(stateId: lastId, creator: lastPresentation);
    }

    final pageCreators = <PageCreatorWithId<S, E>>[];
    for (final stateId in _stateIds) {
      final presentation = _mapping[stateId];
      if (presentation is PageCreator<dynamic, S, E>) {
        pageCreators.add(PageCreatorWithId(stateId, presentation));
      }
    }

    for (var i = 0;
        i < (lastPage == null ? pageCreators.length : pageCreators.length - 1);
        i++) {
      final creatorWithId = pageCreators[i];
      pages.add(
        creatorWithId.creator.create(
          name: '${_machine.name}-${creatorWithId.stateId}',
          widget: creatorWithId.creator.widget,
        ),
      );
    }

    if (lastPage != null) {
      pages.add(lastPage);
    }

    return pages;
  }

  void _cleanUpCircle(S from) {
    final toRemove = <S>[];
    for (var i = _stateIds.length - 1; i >= 0; i--) {
      final stateId = _stateIds[i];
      if (stateId == from) break;
      toRemove.add(stateId);
    }

    for (final id in toRemove) {
      _stateIds.remove(id);
    }
  }

  Page<dynamic> _addPageless({
    required S stateId,
    required PagelessCreator<dynamic, E> creator,
  }) {
    final machineName = _machine.name;
    final lastPageCreatorWithId = _getLastPageCreator();
    final lastPageWithPageless = lastPageCreatorWithId.creator.create(
      name: '${_machine.name}-${lastPageCreatorWithId.stateId}',
      widget: Builder(
        builder: (context) {
          _log.finest(
            () => '_addPageless: builder for pageless '
                '$machineName - ${_machine.activeStateId}'
                ' into page ${lastPageCreatorWithId.stateId}',
          );
          // We schedule execution of pagelessCreator.open for next cycle.
          Future.delayed(Duration.zero, () async {
            _log.finest(
              () => '_addPageless: ${_machine.activeStateId}, $stateId',
            );
            if (_machine.activeStateId == stateId) {
              _log.finest(
                () => '_addPageless: Opening pageless '
                    '$machineName - ${_machine.activeStateId}'
                    ' into page ${lastPageCreatorWithId.stateId}',
              );
              _pageless = creator;
              final dynamic result = await creator.open(context);
              _log.finest(
                () => '_addPageless: COMPLETED ${_machine.name},$machineName -'
                    ' $stateId',
              );
              _log.info(() => 'pagelessCreator.open result is $result.');
              // Only clear _pageless (and optionally fire its event) if it was
              // still our _pageless. If it was already closed (and nulled) and
              // optionally already set to a new PagelessCreator (happens when
              // next state was also mapped to a PagelessCreator) we shall not
              // act here.
              // TODO: Create test for this.
              if (_pageless == creator) {
                _pageless = null;
                final event = creator.event;
                if (event != null) {
                  await _machine.fire(event, arg: result);
                }
              }
            }
          });

          return lastPageCreatorWithId.creator.widget;
        },
      ),
    );

    return lastPageWithPageless;
  }

  PageCreatorWithId<S, E> _getLastPageCreator() {
    for (var i = _stateIds.length - 1; i >= 0; i--) {
      final stateId = _stateIds[i];
      final presentation = _mapping[stateId];
      if (presentation is PageCreator<dynamic, S, E>) {
        return PageCreatorWithId(stateId, presentation);
      }
    }

    throw ArgumentError('No PageCreator in _stateIds.'
        ' Pageless routes can only be added on top of a paged route.');
  }
}

class PageCreatorWithId<S, E> {
  PageCreatorWithId(this.stateId, this.creator);

  final S stateId;
  final PageCreator<dynamic, S, E> creator;
}

class PagelessCreatorWithId<S, E> {
  PagelessCreatorWithId(this.stateId, this.creator);

  final S stateId;
  final PagelessCreator<dynamic, E> creator;
}

/*
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
*/
