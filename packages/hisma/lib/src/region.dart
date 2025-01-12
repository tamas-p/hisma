import 'machine.dart';
import 'notification.dart';
import 'trigger.dart';

/// Region represents one child machine (sub-machine) of the enclosing state
/// together with the corresponding connection points: EntryPoints
/// and ExitPoints.
class Region<S, E, T, SS> {
  Region({
    required this.machine,
    this.entryConnectors,
    this.exitConnectors,
  }) {
    // Set child machine's notifyRegion to let it notify us (this region).
    machine.notifyRegion = _processMachineNotification;
    // machine.notifyStateChange = notifyStateChange;
    // machine.parentId = parentId;
  }

  // Enclosing state machine will select based on the trigger composed of
  // source state, source event and optionally transition the entry point
  // and will send the there configured event for the given child machine.
  final Map<Trigger<S, E, T>, SS>? entryConnectors;

  // Enclosing state machine will use the received ExitPoint from a child
  // machine and generate event that will select from the corresponding
  // transitions based on guards and priorities.
  final Map<SS, E>? exitConnectors;

  // We use dynamic here indicating that it will only be defined by the
  // constructor 'machine' parameter.
  final Machine<SS, dynamic, dynamic> machine;

  /// Notifies enclosing state about an event to be processed as
  /// a result of child machine exit.
  late final Future<void> Function(Message notification) notifyState;

  /// This method is given the child state machines of the region. Child
  /// state machine will invoke it with [exitPointId] which this method uses
  /// to find the corresponding event that is connected to the child's
  /// exitPointId.
  Future<void> _processMachineNotification(
    Message notification,
  ) async {
    if (notification is ExitNotificationFromMachine) {
      final event = exitConnectors?[notification.exitPointId];
      assert(
        event != null,
        'No connecting event for exitPointId "${notification.exitPointId}"',
      );
      if (event == null) return;
      await notifyState.call(
        ExitNotificationFromRegion(event: event, arg: notification.arg),
      );
    } else {
      await notifyState.call(notification);
    }
  }
}
