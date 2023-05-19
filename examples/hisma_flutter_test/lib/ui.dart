import 'package:flutter/material.dart';

import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';

import 'machine.dart';

String getTitle(hisma.StateMachine<S, E, T> machine, S? stateId) =>
    'Title ${getName(machine.name, stateId)}.';

class Screen extends StatelessWidget {
  const Screen(this.machine, this.stateId, {super.key});

  final hisma.StateMachine<S, E, T> machine;
  final S stateId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle(machine, stateId)),
      ),
      body: _createButtonsFromState(machine.states[stateId]),
    );
  }

  Widget _createButtonsFromState(
    hisma.BaseState<dynamic, dynamic, dynamic>? state,
  ) {
    final buttons = <Widget>[];
    if (state is! hisma.State) throw ArgumentError();
    for (final eventId in state.etm.keys) {
      buttons.add(
        TextButton(
          onPressed: () async {
            print('Screen: state.machine.fire($eventId) - ${machine.name}');
            await state.machine.fire(eventId);
          },
          child: Text('$eventId'),
        ),
      );
    }

    return Column(children: buttons);
  }
}

class DialogCreator extends PagelessCreator<E, E> {
  DialogCreator({
    required this.machine,
    required this.stateId,
    super.event,
  });

  final hisma.StateMachine<S, E, T> machine;
  final S stateId;

  BuildContext? _context;

  @override
  Future<E?> open(BuildContext context) {
    return showDialog<E>(
      // useRootNavigator: false,
      context: context,
      builder: (context) {
        _context = context;
        return AlertDialog(
          title: Text(getTitle(machine, stateId)),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[Text('text')],
            ),
          ),
          actions: _createButtonsFromState(),
        );
      },
    );
  }

  @override
  void close([E? value]) {
    final context = _context;
    // if (context != null && context.mounted) {
    if (context != null) Navigator.of(context, rootNavigator: true).pop(value);
    // }
  }

  List<Widget> _createButtonsFromState() {
    final buttons = <Widget>[];
    final state = machine.states[stateId];
    if (state is! hisma.State<E, T, S>) throw ArgumentError();

    for (final eventId in state.etm.keys) {
      buttons.add(
        TextButton(
          onPressed: () {
            close(eventId);
          },
          // onPressed: eventId != E.self
          //     ? () {
          //         close(eventId);
          //       }
          //     : null,
          child: Text('$eventId'),
        ),
      );
    }

    return buttons;
  }
}

class DatePickerPagelessRouteManager extends PagelessCreator<DateTime, E> {
  DatePickerPagelessRouteManager({
    required this.firstDate,
    required this.initialDate,
    required this.currentDate,
    required this.lastDate,
    super.event,
  });

  final DateTime firstDate;
  final DateTime initialDate;
  final DateTime currentDate;
  final DateTime lastDate;

  BuildContext? _context;
  @override
  Future<DateTime?> open(BuildContext context) {
    _context = context;
    return showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initialDate,
      currentDate: currentDate,
      lastDate: lastDate,
    );
  }

  @override
  void close([DateTime? value]) {
    final context = _context;
    if (context != null) Navigator.of(context, rootNavigator: true).pop(value);
  }
}

class SnackbarPagelessRouteManager
    extends PagelessCreator<SnackBarClosedReason, E> {
  SnackbarPagelessRouteManager({
    required this.text,
    super.event,
  });

  final String text;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? ret;

  @override
  Future<SnackBarClosedReason> open(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(text),
      // backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {},
      ),
    );

    ret = ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return ret!.closed;
  }

  @override
  void close([void value]) {
    ret?.close();
  }
}