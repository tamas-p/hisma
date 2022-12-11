import 'package:hisma/hisma.dart';
import 'package:hisma_extra/hisma_extra.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

final machine = ToggleStateMachine(name: 'toggleMachine');

Future<void> play() async {
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    await machine.toggle();
  }
}

void main(List<String> args) {
  StateMachine.monitorCreators = [
    (machine) => VisualMonitor(machine),
  ];

  machine.start();
  play();
}
