/*
import 'package:flutter/widgets.dart';

import 'assistance.dart';
import 'creator.dart';
import 'state_machine_with_change_notifier.dart';
TODO: delete
class HismaPagelessHandler<S, E> {
  HismaPagelessHandler(this._machine, this._mapping) {
    // _machine.pagelessHandler = this;
  }

  final _log = getLogger('$HismaPagelessHandler');

  /// Machine that this router delegate represents.
  final StateMachineWithChangeNotifier<S, E, dynamic> _machine;

  /// Mapping machine states to a presentation. It is defined in
  /// HismaRouterGenerator constructor.
  final Map<S, Presentation> _mapping;

  /// There can be only one pageless route shown at a time in the application.
  static OldPagelessCreator<dynamic, dynamic>? shown;

  static void close() {
    if (shown != null) {
      // shown?.close();
      // shown = null;
    }
  }

  bool isPageless(S stateId) {
    final creator = _mapping[stateId];
    return creator is OldPagelessCreator<dynamic, E>;
  }

  Future<void> openPageless({
    required S stateId,
    required BuildContext context,
  }) async {
    final creator = _mapping[stateId];
    if (creator is! OldPagelessCreator<E, dynamic>) {
      throw ArgumentError('Not pageless but $creator');
    }

    _log.finest(
      () => '_addPageless: Opening pageless '
          '${_machine.name} - ${_machine.activeStateId}',
    );
    shown = creator;
    final dynamic result = await creator.open(context);
    _log.finest(
      () => '_addPageless: COMPLETED ${_machine.name}, - $stateId',
    );
    _log.info(() => 'pagelessCreator.open result is $result.');

    // print('openPageless: Starting waiting...');
    // await Future.delayed(const Duration(seconds: 6), () {
    //   print('openPageless: DONE waiting.');
    // });
    // print('openPageless: DONE.');

    // SchedulerBinding.instance.addPostFrameCallback((_) {});

    // Only clear _pageless (and optionally fire its event) if it was
    // still our _pageless. If it was already closed (and nulled) and
    // optionally already set to a new PagelessCreator (happens when
    // next state was also mapped to a PagelessCreator) we shall not
    // act here.
    // TODO: Create test for this.
    if (shown == creator) {
      shown = null;
      final event = creator.event;
      if (event != null) {
        await _machine.fire(
          event,
          arg: result ?? context,
          // context: context,
        );
        _log.fine('Fire completed: $event arg: $result');
      }
    }
  }
}
*/
