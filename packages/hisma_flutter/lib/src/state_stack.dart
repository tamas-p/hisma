import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'assistance.dart';
import 'creator.dart';

class StateStack {
  StateStack();

  final LinkedHashMap<String, Presentation> _stack =
      LinkedHashMap<String, Presentation>();

  final _log = getLogger('$StateStack');

  void printIt(String str) {
    if (!kDebugMode) return;
    _log.finest('>>> $str >>>');
    final list = _stack.entries.toList();
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      _log.finest('$i. ${e.key} : ${e.value}');
    }
    _log.finest('<<<<<<<<<<<<<<<<');
  }

  void clear() {
    _stack.clear();
    printIt('CLEAR');
  }

  void add(String key, Presentation presentation) {
    _stack[key] = presentation;
    printIt('ADD($key)');
  }

  void remove(String? key) {
    _stack.remove(key);
    printIt('REMOVE($key)');
  }

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

  void windBackTo(
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

  void windBackAll(void Function(String, Presentation) processor) {
    // Avoid concurrent mod. exception.
    final cpy = LinkedHashMap<String, Presentation>.from(
      _stack,
    );
    for (final current in cpy.entries.toList().reversed) {
      processor(current.key, current.value);
    }
  }

  bool hasImperatives(String key) {
    final keys = _stack.keys.toList();
    for (var i = keys.indexOf(key); i < keys.length; i++) {
      if (_stack[keys[i]] is ImperativeCreator) return true;
    }
    return false;
  }

  bool isLast(String key) {
    return _stack.keys.toList().indexOf(key) == _stack.length - 1;
  }
}
