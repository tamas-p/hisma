import 'creator.dart';

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
