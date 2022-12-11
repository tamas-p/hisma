import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;

Widget createButtonsFromStates(
  List<hisma.BaseState<dynamic, dynamic, dynamic>?> states,
) {
  final buttons = <Widget>[];
  for (final state in states) {
    if (state is! hisma.State) continue;
    for (final eventId in state.etm.keys) {
      buttons.add(
        TextButton(
          onPressed: () => state.machine.fire(eventId),
          child: Text('$eventId'),
        ),
      );
    }
  }

  return Column(children: buttons);
}
