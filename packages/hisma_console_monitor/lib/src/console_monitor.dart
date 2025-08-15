import 'dart:io';

import 'package:hisma/hisma.dart';

import 'active_state_visualizer.dart';

/// When configured for [Machine] it reports (by default to the console)
/// creation and state changes of this machine included with all its compounded
/// state machines.
class ConsoleMonitor implements Monitor {
  /// The [stateMachine] is the state machine to be monitored.
  /// [printer] defines a function we want monitor to use to
  /// output machine structure. If not given the default implementation
  /// will use [stdout.write].
  /// When [includeInactive] is `false` only the active machines and their
  /// active state will be present in the output.
  ConsoleMonitor(
    this.stateMachine, {
    this.printer = _simplePrint,
    this.includeInactive = true,
  });

  final Machine<dynamic, dynamic, dynamic> stateMachine;
  final void Function(String) printer;
  final bool includeInactive;

  static void _simplePrint(String str) {
    stdout.write(str);
  }

  @override
  Future<void> notifyCreation() async {
    _printActiveStates('created');
  }

  @override
  Future<void> notifyStateChange() async {
    _printActiveStates('state changed');
  }

  void _printActiveStates(String reason) {
    final states = stateMachine.getStructureRecursive(
      includeInactive: includeInactive,
    );

    printer('Machine ${stateMachine.name} monitoring> '
        '$reason:\n${pretty(states)}');
  }
}
