import 'package:flutter/material.dart';

import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

import 'states_events_transitions.dart';

String getTitle(hisma.StateMachine<S, E, T> machine, S? stateId) =>
    '${machine.name} - $stateId';

String getButtonTitle(hisma.StateMachine<S, E, T> machine, dynamic event) =>
    '$event';

class Screen extends StatelessWidget {
  Screen(this.machine, this.stateId, {super.key});
  final Logger _log = Logger('$Screen');

  final StateMachineWithChangeNotifier<S, E, T> machine;
  final S stateId;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(getTitle(machine, stateId)),
          ),
          body: _createButtonsFromState(machine.states[stateId], context),
        );
      },
    );
  }

  Widget _createButtonsFromState(
    hisma.BaseState<dynamic, dynamic, dynamic>? state,
    BuildContext context,
  ) {
    final buttons = <Widget>[];
    if (state is! hisma.State) throw ArgumentError();
    for (final eventId in state.etm.keys) {
      assert(machine == state.machine);
      buttons.add(
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                _log.info(
                  () =>
                      'Screen: state.machine.fire($eventId) - ${machine.name}',
                );
                await machine.fire(
                  eventId as E,
                  context: context,
                );
              },
              child: Text(getButtonTitle(machine, eventId)),
            );
          },
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

/*
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
*/
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

    // final ScaffoldFeatureController<dynamic, void> ret2 =
    //     Scaffold.of(context).showBottomSheet<void>((context) {
    //   return Container();
    // });

    return ret!.closed;
  }

  @override
  void close([void value]) {
    ret?.close();
  }
}
