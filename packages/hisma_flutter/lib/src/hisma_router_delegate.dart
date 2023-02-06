import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'assistance.dart';
import 'creator.dart';
import 'hisma_navigator.dart';
import 'hisma_router_generator.dart';

/*
class StatePresentationPair<W, S> {
  StatePresentationPair({
    required this.state,
    required this.creator,
  });
  final S state;
  final PageCreator<W, S> creator;
}
*/

class StateCreatorPair<P, S> {
  StateCreatorPair({
    required this.state,
    required this.creator,
  });
  final S state;
  final P creator;
}

class HismaRouterDelegate<S, W, E> extends RouterDelegate<S>
    with ChangeNotifier {
  HismaRouterDelegate(this._routerGenerator) {
    _routerGenerator.machine.addListener(notifyListeners);
  }

  static final _log = getLogger('$HismaRouterDelegate');

  @override
  void notifyListeners() {
    final state = _routerGenerator.machine.activeStateId;
    final creator = _routerGenerator.creators[state];
    assert(
      creator != null || state == null,
      '$state state is not defined in HismaRouterGenerator.creators.',
    );

    if (state != _lastState && (state == null || creator is! NoUIChange)) {
      // We only need to rebuild if
      // - state actually changed
      // - machine is stopped (active state is null) OR
      // - we have creator for the active state.
      super.notifyListeners();
    }
  }

  final HismaRouterGenerator<S, W, E> _routerGenerator;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Stores ids of pages that are shown. It is from Strings as we need
  /// to check this in [HismaNavigator]'s popPage (route.settings.name).
  final _shown = <String>{};

  /// Stores states that build up the stack as overlays.
  final _stack = <S>[];

  /// Saving last used context to be able show/pop pageless routes.
  late BuildContext? _lastContext;

  /// This saves last state for those cases when state machine is already
  /// stopped but we have to render. It happens when pageless route is created
  /// and a lower layer page must be created that includes a sub-router.
  /// TODO: It is a hack. We shall not rebuild the page, but with this approach
  /// it will be rebuild as the page changes due to the included Future to show
  /// pageless routes.
  /// TODO: Can not we simply use the top of the _stack?
  S? _lastState;

  @override
  Widget build(BuildContext context) {
    _log.info('build');
    final tmp = _routerGenerator.machine.activeStateId;
    late final S? state;
    late final bool cleanup;
    if (tmp == null) {
      // Machine was stopped, so we clean up right before build returns.
      cleanup = true;
      state = _lastState;
    } else {
      cleanup = false;
      _lastState = state = tmp;
    }
    // Allow type propagation -> non need for state! after this.
    if (state == null) throw Exception(_errorMachineNotRunning());

    final pages = <Page<W>>[];

    if (_stack.contains(state)) {
      // A circle is closing -> we have to clear it backwards.
      _clear(state);
      // _buildUp(pages, state);

      // final first = _stack.indexOf(state);
      // _stack.removeRange(first + 1, _stack.length);
    }

    // No circle -> processing new creator.
    final creator = _routerGenerator.creators[state];
    if (creator is PageCreator<W, S> &&
        creator is! OverlayPageCreator<W, S, E>) {
      // New page is a simple page -> replacing all stack.
      _clearStackAndAddSimplePage(state, creator, pages);
    } else {
      // New page is an overlay -> adding to stack.
      if (creator is OverlayPageCreator<W, S, E>) {
        _addOverlayPage(state, creator, pages);
      } else if (creator is PagelessCreator<E, dynamic>) {
        _addPagelessRoute(state, creator, pages);
      } else {
        assert(false, 'At $state $creator is not handled.');
      }
    }

    _log.fine('machine=${_routerGenerator.machine.name}');
    _log.fine('_stack=$_stack');
    _log.fine('_shown=$_shown');

    if (cleanup) {
      _shown.clear();
      _stack.clear();
      _lastState = null;
      // TODO shall we _clean() e.g. AlertDialog(s) here?
      // S.l2a1 --> S.ca1 --> S.ca Why AlertDialog of S.l2a1 is still shown?
      // This only happens when the other state is a PagelessRoute.
    }

    assert(
        pages.isNotEmpty,
        'pages is empty.'
        ' There must be at least one page in the list.'
        ' Your initial state might be a PagelessCreator.'
        ' Please make sure that your initial state is a PageCreator.');

    return HismaNavigator<S, W, E>(
      pages: pages,
      myRouter: _routerGenerator,
      key: _navigatorKey,
      shown: _shown,
    );
  }

  void _clear(S state) {
    final current = _stack.indexOf(state);
    for (var i = _stack.length - 1; i > current; i--) {
      final s = _stack[i];
      if (_shown.contains(s.toString())) {
        final creator = _routerGenerator.creators[s];
        var useRoot = false;
        if (creator is PagelessCreator) {
          useRoot = creator.rootNavigator;
        }

        assert(_lastContext != null);
        Navigator.of(_lastContext!, rootNavigator: useRoot).pop();
      }
      _stack.removeLast();
    }
  }

  bool inOverlayPageGroup() {
    return true;
  }

  Page<W> _createPage(
    S state,
    PageCreator<W, S> creator, {
    void Function(BuildContext)? f,
  }) {
    return creator.create(
      state: state,
      widget: Builder(
        builder: (context) {
          _lastContext = context;
          if (f != null) {
            /// We schedule execution of function 'f' during next build cycle.
            Future.delayed(Duration.zero, () {
              f(context);
            });
          }
          return creator.widget;
        },
      ),
    );
  }

  void _addOverlayPage(
    S state,
    PageCreator<W, S> creator,
    List<Page<W>> pages,
  ) {
    // 1st build up from existing stack.
    for (final s in _stack) {
      final c = _routerGenerator.creators[s];
      assert(c != null);
      if (c is PageCreator<W, S>) {
        pages.add(_createPage(s, c));
      }
    }

    if (!_stack.contains(state)) {
      // Then add new page.
      final page = creator.create(
        state: state,
        widget: creator.widget,
      );
      pages.add(page);

      _stack.add(state);
    }
    _shown.add(state.toString());
  }

  void _clearStackAndAddSimplePage(
    S state,
    PageCreator<W, S> creator,
    List<Page<W>> pages,
  ) {
    // _clear2();
    _stack.clear();
    _shown.clear(); // TODO: do we need this as _shown.remove is auto.
    if (!_stack.contains(state)) _stack.add(state);

    pages.add(_createPage(state, creator));
  }

  void _addPagelessRoute(
    S state,
    PagelessCreator<E, dynamic> creator,
    List<Page<W>> pages,
  ) {
    final stateCreatorPairs = _getPageCreators();
    for (var i = 0; i < stateCreatorPairs.length; i++) {
      final pageCreator = stateCreatorPairs[i].creator;
      pages.add(
        _createPage(
          stateCreatorPairs[i].state,
          pageCreator,
          f: i == (stateCreatorPairs.length - 1) &&
                  !_shown.contains(state.toString())
              ? (BuildContext context) async {
                  _lastContext = context;
                  _shown.add(state.toString());
                  final dynamic result = await creator.show.call(context);
                  _shown.remove(state.toString());

                  // Only fire if we are still in the state we were created.
                  // It avoids unwanted fire() in case we got here by a fire().
                  if (_routerGenerator.machine.activeStateId == state) {
                    await _routerGenerator.machine
                        .fire(creator.event, arg: result);
                  }
                }
              : null,
        ),
      );
    }

    if (!_stack.contains(state)) _stack.add(state);
  }

  /// Gets back list of StateCreatorPairs of all states in the _stack
  /// that are of type PageCreator.
  List<StateCreatorPair<PageCreator<W, S>, S>> _getPageCreators() =>
      _getCreators<PageCreator<W, S>>();

  // List<StateCreatorPair<PagelessCreator<E, S>, S>> _getPagelessCreators() =>
  //     _getCreators<PagelessCreator<E, S>>();

  /// Gets back list of StateCreatorPairs of all states in the _stack
  /// that are of type T.
  List<StateCreatorPair<T, S>> _getCreators<T>() => _stack
      .where(
        (state) => _routerGenerator.creators[state] is T,
      )
      .map(
        (state) => StateCreatorPair(
          state: state,
          creator: _routerGenerator.creators[state] as T,
        ),
      )
      .toList();

  @override
  Future<bool> popRoute() {
    // TODO: We shall allow exit from the app here by returning false.
    _log.info('popRoute');
    return SynchronousFuture<bool>(true);
  }

  @override
  Future<void> setNewRoutePath(S configuration) async {
    // TODO: implement it.
  }

  String _errorMachineNotRunning() =>
      'Error: machine "${_routerGenerator.machine.name}" is not running. '
      'State machine must be running when presentation is to be rendered '
      'based on its state.';
}
