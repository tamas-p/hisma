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
    // TODO implement popRoute
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
      onPopPage: (route, dynamic result) {
        _log.info('onPopPage');
        // TODO implement onPopPage
        return false;
      },
    );
  }

  List<Page<dynamic>> _createPages() {
    final pages = <Page<dynamic>>[];
    final presentation = mapping[machine.activeStateId];
    if (presentation is PageCreator<dynamic, S, E>) {
      final page = presentation.create(
        name: '${machine.name}-${machine.activeStateId}',
        widget: presentation.widget,
      );
      pages.add(page);
    } else {
      throw ArgumentError(
        'Presentation ${presentation.runtimeType} is not handled for ${machine.activeStateId}.'
        ' Check mapping in your HismaRouterGenerator for machine ${machine.name}',
      );
    }
    return pages;
  }
}
