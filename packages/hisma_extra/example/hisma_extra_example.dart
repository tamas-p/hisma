import 'package:hisma/hisma.dart';
import 'package:hisma_extra/hisma_extra.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

void main(List<String> args) {
  Machine.monitorCreators = [
    (machine) => VisualMonitor(machine),
  ];

  machine.start();
  play();
}

final machine = ToggleMachine(name: 'toggleMachine');

Future<void> play() async {
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    await machine.toggle();
  }
}
