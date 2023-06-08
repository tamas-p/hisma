import 'package:flutter/material.dart';

import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

import 'machine.dart';

String getTitle(hisma.StateMachine<S, E, T> machine, S? stateId) =>
    '${machine.name} - $stateId';

String getButtonTitle(hisma.StateMachine<S, E, T> machine, dynamic event) =>
    '$event';

class Screen extends StatelessWidget {
  Screen(this.machine, this.stateId, {super.key});
  final Logger _log = Logger('$Screen');

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
      assert(machine == state.machine);
      buttons.add(
        TextButton(
          onPressed: () async {
            _log.info(
              () => 'Screen: state.machine.fire($eventId) - ${machine.name}',
            );
            await state.machine.fire(eventId);
          },
          child: Text(getButtonTitle(machine, eventId)),
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
  final useRootNavigator = false;

  BuildContext? _context;

  @override
  Future<E?> open(BuildContext context) {
    return showDialog<E>(
      useRootNavigator: useRootNavigator,
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
    if (context != null) {
      // TODO: Replace with context.mounted if move to Flutter version > 3.7.
      try {
        (context as Element).widget;
        // print('--- <context is OK> ---');
        Navigator.of(context, rootNavigator: useRootNavigator).pop(value);
      } catch (e) {
        print('** NO RENDEROBJECT FOUND **');
        print('Exception: $e');
      }
    }
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
          child: Text(getButtonTitle(machine, eventId)),
        ),
      );
    }

    return buttons;
  }

  @override
  bool get mounted {
    final context = _context;
    if (context != null) {
      // TODO: Replace with context.mounted if move to Flutter version > 3.7.
      try {
        (context as Element).widget;
        return true;
      } catch (e) {
        return false;
      }
    }

    return false;
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
  bool get mounted {
    final context = _context;
    if (context != null) {
      // TODO: Replace with context.mounted if move to Flutter version > 3.7.
      try {
        (context as Element).widget;
        return true;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

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
  // TODO: remove
  bool get mounted => true;

  @override
  void close([void value]) {
    ret?.close();
  }
}
