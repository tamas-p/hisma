import 'package:logging/logging.dart';

import 'hisma_exception.dart';

/// Generic policy
class ReactionPolicy {
  const ReactionPolicy(this._reactions);

  final Set<Reaction> _reactions;

  void act(Logger log, Object? message) {
    if (_reactions.contains(Reaction.log)) {
      log.fine(message);
    }
    if (_reactions.contains(Reaction.assertion)) {
      assert(false, _objectToString(message));
    }
    if (_reactions.contains(Reaction.exception)) {
      throw HismaInvalidOperationException(_objectToString(message));
    }
  }

  String _objectToString(Object? message) {
    final Object? tmp;
    if (message is Function) {
      tmp = (message as Object? Function()).call();
    } else {
      tmp = message;
    }
    return tmp is String ? tmp : tmp.toString();
  }
}

enum Reaction {
  /// Log the error.
  log,

  /// Raise an assertion.
  assertion,

  /// Throw an exception.
  exception,
}
