import 'package:flutter/cupertino.dart';

import '../hisma_flutter.dart';
import 'assistance.dart';

class StateStack<S> {
  StateStack(this.mapping);
  final Map<S, Presentation> mapping;

  final List<S> _stateIds = [];

  // TODO: Can we avoid exposing the list?
  // List<S> get list => _stateIds;

  void clear() => _stateIds.clear();
  void add(S stateId) => _stateIds.add(stateId);
  void remove(S stateId) => _stateIds.remove(stateId);
  void removeByStr(String? stateIdStr) =>
      _stateIds.removeWhere((element) => element.toString() == stateIdStr);
  void removeList(List<S> stateIds) =>
      _stateIds.removeWhere((element) => stateIds.contains(element));

  void cleanUpCircle(S activeStateId) {
    _stateIds.removeRange(
      _stateIds.indexOf(activeStateId) + 1,
      _stateIds.length,
    );
  }

  bool contains(S? stateId) => _stateIds.contains(stateId);

  void goThrough(void Function(S stateId) processor) {
    for (final current in _stateIds) {
      processor(current);
    }
  }

  // TODO: Remove
  void windBack(S target, void Function(S stateId) processor) {
    assert(contains(target));
    final cpy = List<S>.from(_stateIds); // Avoid concurrent mod. exception.
    for (final current in cpy.reversed) {
      if (current == target) break;
      processor(current);
    }
  }

  /// Gives back whether jumping to the given stateId will pass PageCreators.
  bool intermediatePageCreator(S stateId) {
    if (contains(stateId)) {
      for (final s in _stateIds.reversed) {
        if (s == stateId) break;
        if (mapping[s] is PageCreator) return true;
      }
    }
    return false;
  }

  bool isNext(S stateId, bool Function(Presentation?) next) {
    final i = _stateIds.indexOf(stateId);
    if (_stateIds.length > i + 1) {
      final nextStateId = _stateIds[i + 1];
      if (next(mapping[nextStateId])) return true;
    }
    return false;
  }

  bool hasImperatives(S stateId) =>
      isNext(stateId, (presentation) => presentation is ImperativeCreator);

  bool rightBeforePage(S stateId) =>
      isNext(stateId, (presentation) => presentation is PageCreator);

  bool isLast(S stateId) {
    return _stateIds.indexOf(stateId) == _stateIds.length - 1;
  }
}

class StateStackOld<S> with ChangeNotifier {
  /// We initialize the stack here as we do not need to notify the router
  /// delegate when the machine starts as the build of the delegate will be
  /// called by the framework at start.
  StateStackOld({required this.mapping, required S initialState}) {
    _stateIds.add(initialState);
  }

  // ignore: unused_field
  final _log = getLogger('$StateStackOld');

  /// Mapping machine states to a presentation. It is defined in
  /// HismaRouterGenerator constructor.
  final Map<S, Presentation> mapping;

  final List<S> _stateIds = [];

  void newState(S newState, [BuildContext? context]) {
    if (_stateIds.contains(newState)) {
      _cleanUpCircle(newState);
    } else {
      _addState(newState);
    }
  }

  void _addState(S newState) {
    final presentation = mapping[newState];
    if (presentation is PageCreator) {
      if (presentation.overlay == false) _stateIds.clear();
      _stateIds.add(newState);
      notifyListeners();
    } else if (presentation is OldPagelessCreator) {
      _stateIds.add(newState);
    } else if (presentation is NoUIChange) {
      // Explicit no update was requested, so we do nothing.
    } else {
      throw ArgumentError(
        'Presentation ${presentation.runtimeType} is not handled for $newState.',
      );
    }
  }

  void _cleanUpCircle(S newState) {}

  Future<void> openPageless({
    required S stateId,
    required BuildContext context,
  }) async {
    // ignore: unused_local_variable
    final creator = mapping[stateId];
    // TODO: Fix this:
    // if (creator is! PagelessCreator<dynamic, E>) {
    //   throw ArgumentError('Not pageless but $creator');
    // }

    // TODO: Fix this:
    // _log.finest(
    //   () => '_addPageless: Opening pageless '
    //       '${_machine.name} - ${_machine.activeStateId}',
    // );

    // final dynamic result = await creator.open(context);

    // TODO: Fix this:
    // _log.finest(
    //   () => '_addPageless: COMPLETED ${_machine.name}, - $stateId',
    // );

    // _log.info(() => 'pagelessCreator.open result is $result.');

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
    // final event = creator.event;

    // TODO: Fix this:
    // if (event != null) {
    //   await _machine.fire(
    //     event,
    //     arg: result ?? context,
    //     // context: context,
    //   );
    // _log.fine('Fire completed: $event arg: $result');
  }
}
