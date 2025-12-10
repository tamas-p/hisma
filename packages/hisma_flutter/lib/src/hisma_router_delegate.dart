import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'assistance.dart';
import 'creator.dart';
import 'navigation_machine.dart';
import 'state_stack.dart';

class HismaRouterDelegate<S, E> extends RouterDelegate<S> with ChangeNotifier {
  HismaRouterDelegate({
    required this.machine,
    required this.mapping,
  }) : assert(
            machine.history == null,
            'Machine (name: ${machine.name}) shall not have history defined when used with '
            'HismaRouterDelegate as we can not simply jump (as history would '
            'imply) to a state on the UI, rather it is a path that leads to a '
            'certain UI state.') {
    // Machine changes will result notifying listeners of this
    // router delegate that is the corresponding RouterState, which
    // in turn will call setState to schedule its rebuild and that is
    // delegated to the build method of this class.
    machine.addListener(notifyListeners);

    // We make the machine know its corresponding HismaRouterDelegate.
    // Machine will use it to handle ImperativeCreators.
    machine.routerDelegate = this;
  }

  @override
  Widget build(BuildContext context) {
    _log.info('build');
    return _buildNavigator();
  }

  /// Handles the back button request from the operating system.
  /// Having an event defined for the corresponding Creator and that the machine
  /// is active this event will be fired and true returned. If the machine is
  /// not active false is returned indicating that the popRoute was not handled.
  @override
  Future<bool> popRoute() {
    _log.info('popRoute');
    if (machine.activeStateId == null) {
      _log.info('popRoute called but machine ${machine.name} is not active.');
      return SynchronousFuture<bool>(false);
    }
    _fire(result: null, uiClosed: false);
    return SynchronousFuture<bool>(true);
  }

  @override
  Future<void> setNewRoutePath(S configuration) {
    _log.info('setNewRoutePath($configuration)');
    // TODO: implement setNewRoutePath
    return SynchronousFuture(null);
  }

  @override
  S? get currentConfiguration {
    return machine.activeStateId;
  }

  //----------------------------------------------------------------------------

  final _log = getLogger('$HismaRouterDelegate');

  /// Required to find NavigatorState corresponding to this RouterDelegate.
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Machine that this router delegate represents.
  final NavigationMachine<S, E, dynamic> machine;

  /// Mapping machine states to a presentation.
  final Map<S, Presentation> mapping;

  //----------------------------------------------------------------------------

  Widget _buildNavigator() {
    _log.info(() => 'm: ${machine.name}, st: ${machine.activeStateId}');
    return Navigator(
      key: navigatorKey,
      pages: _createPages(),
      onPopPage: _onPopPage,
    );
  }

  Route<dynamic>? _previousRoutePopped;
  bool _onPopPage(Route<dynamic> route, dynamic result) {
    // We need to make sure that we are not processing the same route
    // multiple times as _onPopPage can be called multiple times for
    // the same route e.g. when user presses device back button multiple
    // times quickly. See t04_imperative_test.dart android double tap
    // back button test.
    if (route == _previousRoutePopped) return false;
    _previousRoutePopped = route;

    final didPop = route.didPop(result);
    if (didPop) {
      stack.remove(route.settings.name);
      final activeKey = getKey(machine.name, machine.activeStateId);
      if (route.settings.name == activeKey) {
        // We only fire if we are in the same state when the route
        // from the presentation -> page -> route was created.
        // Being in a different state indicates that there ended up here
        // as a result a previous fire (that moved to another state) hence
        // we shall not trigger another fire.
        _fire(result: result, uiClosed: true);
      }
    }
    return didPop;
  }

  void _fire({required dynamic result, required bool uiClosed}) {
    final presentation = mapping[machine.activeStateId];
    assert(presentation is Creator<E>, '$presentation is not a Creator<$E>.');
    if (presentation is Creator<E>) {
      final event = presentation.event;
      assert(
          !uiClosed || event != null,
          '$presentation defined for ${machine.activeStateId}'
          ' shall have its event set.');
      if (event != null) {
        machine.fire(event, arg: uiClosed ? UiClosed(result) : result);
      }
    }
  }

  final stack = StateStack();

  var _previousPages = <Page<dynamic>>[];
  List<Page<dynamic>> _createPages() {
    final presentation = mapping[machine.activeStateId];
    final activeStateId = machine.activeStateId;
    // We only process if machine is active and the active state is a
    // PageCreator. In other cases we simply return the previously created
    // pages list.
    if (activeStateId == null || presentation is! PageCreator) {
      assert(
        _previousPages.isNotEmpty,
        'No previous pages. Active state: $activeStateId, '
        'presentation: $presentation',
      );
      return _previousPages;
    } else {
      // We only process the state if it is not leading us back to a previous
      // state in a circle that current _pageMap (hence current navigator pages)
      // includes.
      if (stack.contains(getKey(machine.name, activeStateId))) {
        // Since we arrived back to a state that (more precisely the page
        // created by its Presentation) is already in the current
        // Navigator.pages (through the circle in the state transition graph),
        // we have to clean up the pages on the circle.
        stack.cleanUpCircle(getKey(machine.name, activeStateId));
      } else {
        // This state (more precisely the page created by its Presentation) is
        // not represented in Navigator.pages hence we need to add it.
        _addState(activeStateId);
      }
      return _previousPages = _stateIdsToPages();
    }
  }

  List<Page<dynamic>> _stateIdsToPages() {
    final pages = <Page<dynamic>>[];
    stack.goThrough((String key, Presentation presentation) {
      if (presentation is PageCreator) {
        pages.add(
          presentation.create(
            name: key,
            widget: presentation.widget,
          ),
        );
      }
    });
    assert(pages.isNotEmpty);
    return pages;
  }

  void _addState(S stateId) {
    _log.fine('_addState($stateId)');
    final presentation = mapping[stateId];
    assert(presentation != null, missingPresentationMsg(stateId, machine.name));
    assert(presentation is PageCreator);

    if (presentation is PageCreator<E, dynamic>) {
      if (presentation.overlay == false) stack.clear();
      stack.add(getKey(machine.name, stateId), presentation);
    }
  }
}
