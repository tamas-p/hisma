import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'assistance.dart';
import 'creator.dart';
import 'state_machine_with_change_notifier.dart';

class HismaRouterDelegateNew<S, E> extends RouterDelegate<S>
    with ChangeNotifier {
  HismaRouterDelegateNew({
    required this.machine,
    required this.mapping,
  }) {
    // Machine changes will result notifying listeners of this
    // router delegate that is the corresponding RouterState, which
    // in turn will call setState to schedule its rebuild and that is
    // delegated to the build method of this class.
    machine.addListener(notifyListeners);
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
    doSmg(null);
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

  final _log = getLogger('$HismaRouterDelegateNew');

  /// Required to find NavigatorState corresponding to this RouterDelegate.
  final GlobalKey _navigatorKey = GlobalKey<NavigatorState>();

  /// Machine that this router delegate represents.
  final StateMachineWithChangeNotifier<S, E, dynamic> machine;

  /// Mapping machine states to a presentation.
  final Map<S, Presentation> mapping;

  //----------------------------------------------------------------------------

  Widget _buildNavigator() {
    _log.info(() => 'm: ${machine.name}, st: ${machine.activeStateId}');
    return Navigator(
      key: _navigatorKey,
      pages: _createPages(),
      onPopPage: _onPopPage,
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    doSmg(result);
    return false;
  }

  void doSmg(dynamic result) {
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

  final _stateIds = <S>[];
  List<Page<dynamic>>? _previousPages;
  List<Page<dynamic>> _createPages() {
    final activeStateId = machine.activeStateId;
    final pages = <Page<dynamic>>[];
    // We only process if machine is active. If inactive we simply build
    // pages of the navigator from the current [_stateIds] (that was updated
    // during the previous builds). This is required to handle the case when a
    // child machine gets inactivated but we need its previous presentation to
    // allow the transition (by being the background) to the new page.
    if (activeStateId != null) {
      // We only process the state if it is not leading us back to a previous
      // state in a circle that current _pageMap (hence current navigator pages)
      // includes.
      if (_stateIds.contains(activeStateId)) {
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

      for (final stateId in _stateIds) {
        final presentation = mapping[stateId];
        if (presentation is PageCreator) {
          pages.add(
            presentation.create(
              name: stateId.toString(),
              widget: presentation.widget,
            ),
          );
        } else if (presentation is PagelessCreator) {
          print('PagelessCreator');
        } else {
          throw Exception('NOK');
        }
      }

      assert(pages.isNotEmpty);
      return pages;
    }

    return _previousPages!;
  }

  void _cleanUpCircle(S activeStateId) {
    _log.fine('_cleanUpCircle($activeStateId)');
    for (var i = _stateIds.length - 1; i >= 0; i--) {
      if (_stateIds[i] != activeStateId) {
        _stateIds.removeAt(i);
      } else {
        break;
      }
    }
  }

  void _addState(S stateId) {
    _log.fine('_addState($stateId)');
    final presentation = mapping[stateId];
    if (presentation is PageCreator<E, dynamic>) {
      if (presentation.overlay == false) _stateIds.clear();
      _stateIds.add(stateId);
    } else if (presentation is PagelessCreator<dynamic, E>) {
      _stateIds.add(stateId);
    } else if (presentation is NoUIChange) {
      // Explicit no update was requested, so we do nothing.
    } else {
      throw ArgumentError(
        'Presentation ${presentation.runtimeType} is not handled for $stateId.'
        ' Check mapping in your HismaRouterGenerator for machine ${machine.name}',
      );
    }
  }
}
