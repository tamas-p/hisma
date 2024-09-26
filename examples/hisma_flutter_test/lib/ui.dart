import 'package:flutter/material.dart';

import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

// import 'states_events_transitions.dart';

String getTitle<S, E, T>(hisma.StateMachine<S, E, T> machine, S? stateId) =>
    '${machine.name} - $stateId';

String getButtonTitle<S, E, T>(
  hisma.StateMachine<S, E, T> machine,
  dynamic event,
) =>
    '${machine.name}.$event';

class Screen<S, E, T> extends StatelessWidget {
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
          body: Center(
            child: Column(
              children: _createButtonsFromState(machine, context),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _createButtonsFromState(
    StateMachineWithChangeNotifier<S, E, T> machine,
    BuildContext context,
  ) {
    final state = machine.states[machine.activeStateId];
    final buttons = <Widget>[];
    if (state != null && state is hisma.State<E, T, S>) {
      for (final eventId in state.etm.keys) {
        // assert(machine == state.machine);
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
                    eventId,
                    // arg: context,
                  );
                },
                child: Text(getButtonTitle(machine, eventId)),
              );
            },
          ),
        );
      }
    }

    final parent = machine.parent;
    if (parent != null && parent is StateMachineWithChangeNotifier<S, E, T>) {
      print('parent name: ${parent.name}');
      buttons.add(const Divider());
      buttons.add(Text('from ${parent.name}'));
      buttons.addAll(
        _createButtonsFromState(
          parent,
          context,
        ),
      );
    }

    return buttons;
  }
}

class TestDialogCreator<S, E, T> extends DialogCreator<E, CtxArg> {
  TestDialogCreator({
    required super.event,
    required super.useRootNavigator,
    required this.machine,
    required this.stateId,
  }) : super(
          show: (dc, context) => showDialog(
            useRootNavigator: useRootNavigator,
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(getTitle(machine, stateId)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[Text('text')],
                  ),
                ),
                actions:
                    (dc as TestDialogCreator).createButtonsFromState(context),
              );
            },
          ),
        );

  final hisma.StateMachine<S, E, T> machine;
  final S stateId;

  List<Widget> createButtonsFromState(BuildContext context) {
    final buttons = <Widget>[];
    final state = machine.states[stateId];
    if (state is! hisma.State<E, T, S>) throw ArgumentError();

    for (final eventId in state.etm.keys) {
      buttons.add(
        TextButton(
          onPressed: () {
            close(CtxArg(context, eventId));
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
class SnackbarPagelessRouteManager<S, E, T>
    extends PagelessCreator<E, SnackBarClosedReason> {
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
