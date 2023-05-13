import 'package:logging/logging.dart';

import 'hisma_exception.dart';

/// Generic policy
class ReactionPolicy {
  const ReactionPolicy(this._reactions);

  final Set<Reaction> _reactions;

  void act({required Logger log, required String message}) {
    if (_reactions.contains(Reaction.log)) {
      log.fine(message);
    }
    if (_reactions.contains(Reaction.assertion)) {
      assert(false, message);
    }
    if (_reactions.contains(Reaction.exception)) {
      throw HismaMachinePolicyException(message);
    }
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
