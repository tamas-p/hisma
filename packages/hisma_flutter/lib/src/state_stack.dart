import 'dart:collection';

import 'creator.dart';

/*
class StateStackO<S> {
  StateStackO(this.mapping);
  final Map<S, Presentation> mapping;

  final List<S> _stateIds = [];

  // TODO: Can we avoid exposing the list?
  // List<S> get list => _stateIds;

  void clear() {
    _stateIds.clear();
    print('CLEAR: $_stateIds');
  }

  void add(S stateId) {
    _stateIds.add(stateId);
    print('ADD($stateId): $_stateIds');
  }

  void remove(S stateId) {
    _stateIds.remove(stateId);
    print('REMOVE($stateId): $_stateIds');
  }

  void removeByStr(String? stateIdStr) {
    _stateIds.removeWhere((element) => element.toString() == stateIdStr);
    print('REMOVE_BY_STR($stateIdStr): $_stateIds');
  }
  // void removeList(List<S> stateIds) =>
  //     _stateIds.removeWhere((element) => stateIds.contains(element));

  void cleanUpCircle(S activeStateId) {
    _stateIds.removeRange(
      _stateIds.indexOf(activeStateId) + 1,
      _stateIds.length,
    );
    print('CLEANUP_CIRCLE($activeStateId): $_stateIds');
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
*/
//------------------------------------------------------------------------------

String getKey(String machineName, dynamic stateId) => '$machineName@$stateId';

class StateStack {
  StateStack();

  final LinkedHashMap<String, Presentation> _stack =
      LinkedHashMap<String, Presentation>();

  void printIt(String str) {
    print('>>> $str >>>');
    final list = _stack.entries.toList();
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      print('$i. ${e.key} : ${e.value}');
    }
    print('<<<<<<<<<<<<<<<<');
  }

  void clear() {
    _stack.clear();
    printIt('CLEAR');
  }

  void add(String key, Presentation presentation) {
    _stack[key] = presentation;
    printIt('ADD($key)');
  }

  void remove(String key) {
    _stack.remove(key);
    printIt('REMOVE($key)');
  }

  void removeByStr(String? key) {
    _stack.removeWhere((element, p) => element == key);
    printIt('REMOVE_BY_STR($key)');
  }
  // void removeList(List<S> stateIds) =>
  //     _stateIds.removeWhere((element) => stateIds.contains(element));

  void cleanUpCircle(String key) {
    final keys = _stack.keys.toList();
    for (var i = keys.indexOf(key) + 1; i < keys.length; i++) {
      _stack.remove(keys[i]);
    }
    printIt('CLEANUP_CIRCLE($key)');
  }

  bool contains(String key) {
    final presentation = _stack[key];
    return presentation != null;
  }

  void goThrough(void Function(String key, Presentation) processor) {
    for (final current in _stack.entries) {
      processor(current.key, current.value);
    }
  }

  void windBack(
    String targetKey,
    void Function(Presentation) processor,
  ) {
    assert(contains(targetKey));
    // Avoid concurrent mod. exception.
    final cpy = LinkedHashMap<String, Presentation>.from(
      _stack,
    );
    for (final current in cpy.entries.toList().reversed) {
      if (current.key == targetKey) break;
      processor(current.value);
    }
  }

  /// Gives back whether jumping to the given stateId will pass PageCreators.
  // bool intermediatePageCreator(S stateId) {
  //   if (contains(stateId)) {
  //     for (final s in _stateIds.reversed) {
  //       if (s == stateId) break;
  //       if (mapping[s] is PageCreator) return true;
  //     }
  //   }
  //   return false;
  // }

  bool hasImperatives(String key) {
    final keys = _stack.keys.toList();
    for (var i = keys.indexOf(key); i < keys.length; i++) {
      if (_stack[keys[i]] is ImperativeCreator) return true;
    }
    return false;
  }

  // bool rightBeforePage(S stateId) =>
  //     isNext(stateId, (presentation) => presentation is PageCreator);

  bool isLast(String key) {
    return _stack.keys.toList().indexOf(key) == _stack.length - 1;
  }
}
