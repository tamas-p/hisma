import 'package:hisma/hisma.dart';

import 'active_state_visualizer.dart';

/// When configured for [StateMachine] it reports active states of
/// the hierarchical state machine.
class ConsoleMonitor implements Monitor {
  /// Test
  ///
  /// The [stateMachine] is the state machine to be monitored.
  /// [printer] Defines a function we want monitor to use to
  /// output active states. If not given the default implementation
  /// will use print().
  ConsoleMonitor(
    this.stateMachine, {
    this.printer = _simplePrint,
  });

  final StateMachine<dynamic, dynamic, dynamic> stateMachine;
  final void Function(String) printer;

  static void _simplePrint(String str) {
    // ignore: avoid_print
    print(str);
  }

  @override
  Future<void> notifyCreation() async {
    _printActiveStates();
  }

  @override
  Future<void> notifyStateChange() async {
    _printActiveStates();
  }

  void _printActiveStates() {
    final activeStates = stateMachine.getActiveStateRecursive();
    printer(
      "monitor> '${stateMachine.name}' "
      "active state${activeStates.length > 1 ? 's' : ''}:\n"
      '${pretty(activeStates)}',
    );
  }
}
