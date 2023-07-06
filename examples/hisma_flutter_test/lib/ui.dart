import 'package:flutter/material.dart';

import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

import 'states_events_transitions.dart';

const _loggerName = 'ui';
final Logger _log = Logger(_loggerName);

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

class TestDialogCreator extends DialogCreator<E, E> {
  TestDialogCreator({
    required super.event,
    required super.useRootNavigator,
    required this.machine,
    required this.stateId,
  }) : super(
          show: (dc, context) => showDialog<E>(
            useRootNavigator: useRootNavigator,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(getTitle(machine, stateId)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[Text('text')],
                  ),
                ),
                actions: (dc as TestDialogCreator).createButtonsFromState(),
              );
            },
          ),
        );

  final hisma.StateMachine<S, E, T> machine;
  final S stateId;

  List<Widget> createButtonsFromState() {
    final buttons = <Widget>[];
    final state = machine.states[stateId];
    if (state is! hisma.State<E, T, S>) throw ArgumentError();

    for (final eventId in state.etm.keys) {
      buttons.add(
        TextButton(
          onPressed: () {
            close(eventId);
          },
          child: Text(getButtonTitle(machine, eventId)),
        ),
      );
    }

    return buttons;
  }
}

class TestDialogCreator4 extends DialogCreator3<E, E> {
  TestDialogCreator4({
    required this.machine,
    required this.stateId,
    required super.useRootNavigator,
    required super.event,
  });

  final hisma.StateMachine<S, E, T> machine;
  final S stateId;

  @override
  Future<E?> show(BuildContext context) => showDialog<E>(
        useRootNavigator: useRootNavigator,
        context: context,
        builder: (context) {
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
          child: Text(getButtonTitle(machine, eventId)),
        ),
      );
    }

    return buttons;
  }
}

class TestDialogCreator2 extends PagelessCreator<E, E> {
  TestDialogCreator2({
    required this.machine,
    required this.stateId,
    required this.useRootNavigator,
    super.event,
  });

  final hisma.StateMachine<S, E, T> machine;
  final S stateId;
  final bool useRootNavigator;

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
      // TODO: Even better, this mounted check can be eliminated if monkey shows
      // that it never reaches NO RENDER...
      try {
        (context as Element).widget;
        _log.info('--- <context is OK> ---');
      } catch (e) {
        _log.info('** NO RENDEROBJECT FOUND **');
        _log.info('Exception: $e');
        // exit(1);
        return;
      }
      Navigator.of(context, rootNavigator: useRootNavigator).pop(value);
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

  @override
  // TODO: implement shown
  bool get shown => throw UnimplementedError();
}

class DatePickerPagelessRouteManager extends PagelessCreator<DateTime, E> {
  DatePickerPagelessRouteManager({
    required this.firstDate,
    required this.initialDate,
    required this.currentDate,
    required this.lastDate,
    required this.useRootNavigator,
    super.event,
  });

  final DateTime firstDate;
  final DateTime initialDate;
  final DateTime currentDate;
  final DateTime lastDate;
  final bool useRootNavigator;

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
      useRootNavigator: useRootNavigator,
    );
  }

  @override
  void close([DateTime? value]) {
    final context = _context;
    if (context != null) {
      Navigator.of(context, rootNavigator: useRootNavigator).pop(value);
    }
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
