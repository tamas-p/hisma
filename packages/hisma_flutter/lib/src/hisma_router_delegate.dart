import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'assistance.dart';
import 'creator.dart';
import 'state_machine_with_change_notifier.dart';
import 'state_stack.dart';

class HismaRouterDelegate<S, E> extends RouterDelegate<S> with ChangeNotifier {
  HismaRouterDelegate({
    required this.machine,
    required this.mapping,
  }) /* TODO: assert(
            machine.history == null,
            'Machine shall not have history defined when used with '
            'HismaRouterDelegate as we can not simply jump (as history would '
            'imply) to a state on the UI, rather it is a path that leads to a '
            'certain UI state.'), */
  // stack = StateStack()
  {
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
  /// Having and event defined for the corresponding Creator it will
  /// be fired on the machine. It is always returns true avoiding the
  /// popping of the entire application.
  /// TODO: How to auto test Android back button?
  @override
  Future<bool> popRoute() async {
    _log.info('popRoute');
    _fire(null);
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
  final StateMachineWithChangeNotifier<S, E, dynamic> machine;

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

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    final didPop = route.didPop(result);
    if (didPop) {
      stack.removeByStr(route.settings.name);
      final activeKey = getKey(machine.name, machine.activeStateId);
      if (route.settings.name == activeKey) {
        // We only fire if we are in the same state when the route
        // from the presentation -> page -> route was created.
        // Being in a different state indicates that there ended up here
        // as a result a previous fire (that moved to another state) hence
        // we shall not trigger another fire.

        // TODO: Instead of assert event could be required.
        final pres = mapping[machine.activeStateId];
        assert(
          pres is Creator<E> && pres.event != null,
          'For $pres event shall not be null when its overlay is true.',
        );
        _fire(result);
      }
    }
    return didPop;
  }

  void _fire(dynamic result) {
    final presentation = mapping[machine.activeStateId];
    if (presentation is Creator<E>) {
      final event = presentation.event;
      if (event != null) {
        machine.fire(event, arg: result);
      } else {
        _log.info('No event defined.');
      }
    } else {
      throw Exception('NOK');
    }
  }

  final stack = StateStack();

  late List<Page<dynamic>> _previousPages;
  List<Page<dynamic>> _createPages() {
    final presentation = mapping[machine.activeStateId];
    if (presentation is ImperativeCreator) {
      // TODO: remove this part
      // return _previousPages;
    }

    final activeStateId = machine.activeStateId;
    // We only process if machine is active. If inactive we simply build
    // pages of the navigator from the current [_stateIds] (that was updated
    // during the previous builds). This is required to handle the case when a
    // child machine gets inactivated but we need its previous presentation to
    // allow the transition (by being the background) to the new page.
    if (activeStateId == null) {
      // TODO: It seems we never get here. Do we need this at all?
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
      } else {
        // throw ArgumentError(
        //   'Presentation ${presentation.runtimeType} is not handled.',
        // );
        print('PAGELESS: $presentation @ ${machine.activeStateId}');
      }
    });
    assert(pages.isNotEmpty);
    return pages;
  }

  void _addState(S stateId) {
    _log.fine('_addState($stateId)');
    final presentation = mapping[stateId];
    // TODO: Create unit test to check this assertion.
    assert(presentation != null, missingPresentationMsg(stateId, machine.name));

    if (presentation is PageCreator<E, dynamic>) {
      if (presentation.overlay == false) stack.clear();
      stack.add(getKey(machine.name, stateId), presentation);
    } else if (presentation is ImperativeCreator) {
      // We skip Imperative creators.
    } else if (presentation is NoUIChange) {
      // Explicit no update was requested, so we do nothing.
      // TODO: Since machine will never send notify if pres was NoUIChange
      // we will never get here => this branch can be removed from here.
    } else {
      throw ArgumentError(
        'Presentation ${presentation.runtimeType} is not supported.',
      );
    }
  }
}
