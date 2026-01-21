import 'package:flutter/material.dart';

import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:logging/logging.dart';

// import 'states_events_transitions.dart';

// TODO: We could remove gteMachineName and only use getKey.
String getMachineName<S>(String current, S stateId) => '$current/$stateId';

String getTitle(
  hisma.Machine<dynamic, dynamic, dynamic> machine,
  dynamic stateId,
) =>
    '${machine.name} - $stateId';

String getButtonTitle<S, E, T>(
  hisma.Machine<S, E, T> machine,
  dynamic event,
) =>
    '${machine.name}@${machine.activeStateId}#$event';

class Screen<S, E, T> extends StatefulWidget {
  Screen(this.machine, {this.extra, this.drawer})
      : super(key: ValueKey(machine.activeStateId));
  final NavigationMachine<S, E, T> machine;
  final Builder? extra;
  final Widget? drawer;

  @override
  State<Screen<S, E, T>> createState() => _ScreenState<S, E, T>();
}

class _ScreenState<S, E, T> extends State<Screen<S, E, T>> {
  late final List<Widget> _buttons;
  late final String _title;
  @override
  void initState() {
    super.initState();
    _buttons = createButtonsFromState(widget.machine);
    _title = getTitle(widget.machine, widget.machine.activeStateId);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          drawer: widget.drawer,
          appBar: AppBar(
            title: Text(_title),
          ),
          body: Center(
            child: Column(
              children: [
                ..._buttons,
                if (widget.extra != null) widget.extra!,
              ],
            ),
          ),
        );
      },
    );
  }
}

//------------------------------------------------------------------------------

class MyDialog extends StatefulWidget {
  const MyDialog({super.key, required this.machine});
  final NavigationMachine<dynamic, dynamic, dynamic> machine;

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  _MyDialogState();

  late final String name;
  late final List<Widget> children;

  @override
  void initState() {
    super.initState();
    // name = '${widget.machine.name} @ ${widget.machine.activeStateId}';
    name = getTitle(widget.machine, widget.machine.activeStateId);
    children =
        createButtonsFromState<dynamic, dynamic, dynamic>(widget.machine);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name),
            const Divider(endIndent: 10, indent: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class PresentTestDialog implements Presenter<void> {
  PresentTestDialog(this.machine);
  NavigationMachine<dynamic, dynamic, dynamic> machine;

  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<void> close,
    required dynamic arg,
  }) =>
      showDialog<void>(
        context: context,
        // This is to not completely gray out background when manually testing.
        // This allows visual checks of lower layers in the navigator stack.
        barrierColor: const Color(0x01000000),
        useRootNavigator: rootNavigator,
        builder: (context) {
          return MyDialog(machine: machine);
        },
      );
}

Future<void> showTestDialogMini(
  BuildContext context,
  NavigatorState _,
  Close<void> close,
  NavigationMachine<dynamic, dynamic, dynamic> machine,
) =>
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return const AboutDialog();
      },
    );

class PresentDatePicker implements Presenter<DateTime> {
  @override
  Future<DateTime?> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<DateTime> close,
    required dynamic arg,
  }) =>
      showDatePicker(
        useRootNavigator: rootNavigator,
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1990),
        lastDate: DateTime(2030),
      );
}

//------------------------------------------------------------------------------
/*
class TestDialogCreator<S, E, T> extends OldDialogCreator<E, OldCtxArg> {
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

  final hisma.Machine<S, E, T> machine;
  final S stateId;

  List<Widget> createButtonsFromState(BuildContext context) {
    final buttons = <Widget>[];
    final state = machine.states[stateId];
    if (state is! hisma.State<E, T, S>) throw ArgumentError();

    for (final eventId in state.etm.keys) {
      buttons.add(
        TextButton(
          onPressed: () {
            close(OldCtxArg(context, eventId));
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
    extends OldPagelessCreator<E, SnackBarClosedReason> {
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
*/

String getArgString(dynamic arg) => 'Arg=$arg';

List<Widget> createButtonsFromState<S, E, T>(
  NavigationMachine<S, E, T> machine,
) {
  final log = Logger('createButtonsFromState');
  final state = machine.states[machine.activeStateId];
  final buttons = <Widget>[];
  if (state != null && state is hisma.State<E, T, S>) {
    for (final eventId in state.etm.keys) {
      // assert(machine == state.machine);
      buttons.add(
        TextButton(
          onPressed: () async {
            log.info(
              () => 'Screen: state.machine.fire($eventId) - ${machine.name}',
            );
            await machine.fire(
              eventId,
              arg: getArgString(eventId),
            );
          },
          child: Text(getButtonTitle(machine, eventId)),
        ),
      );
    }
  }

  final parent = machine.parent;
  if (parent != null &&
      parent is NavigationMachine<dynamic, dynamic, dynamic>) {
    // print('parent name: ${parent.name}');
    buttons.add(const Divider());
    buttons.add(Text('from ${parent.name}'));
    buttons.addAll(
      createButtonsFromState<dynamic, dynamic, dynamic>(parent),
    );
  }

  return buttons;
}

// This class is needed to support hot reload as child Routers will
// be rebuilt and lose their HismaRouterDelegate state but the corresponding
// machine active state is preserved. This stateless widget will preserve
// the HismaRouterDelegate.
class RouterWithDelegate<T> extends StatefulWidget {
  const RouterWithDelegate(this.createDelegate, {super.key});
  final RouterDelegate<T> Function() createDelegate;

  @override
  State<RouterWithDelegate<T>> createState() => _RouterWithDelegateState<T>();
}

class _RouterWithDelegateState<RDS> extends State<RouterWithDelegate<RDS>> {
  late final RouterDelegate<RDS> rd;
  @override
  void initState() {
    super.initState();
    rd = widget.createDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return Router<RDS>(
      routerDelegate: rd,
      backButtonDispatcher: Router.of(context)
          .backButtonDispatcher!
          .createChildBackButtonDispatcher()
        ..takePriority(),
    );
  }
}
