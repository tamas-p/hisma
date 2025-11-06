import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

Future<void> main(List<String> args) async {
  h.Machine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];
  final machine = createMachine();
  await machine.start();
  final app = BottomSheetApp(machine: machine, rootNavigator: true);
  runApp(app);
}

class BottomSheetApp extends StatelessWidget {
  BottomSheetApp({
    required this.machine,
    required this.rootNavigator,
    super.key,
  });
  final bool rootNavigator;
  late final gen =
      createGenerator(machine: machine, rootNavigator: rootNavigator);

  final NavigationMachine<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
      routeInformationParser: gen.routeInformationParser,
    );
  }
}

const mainAppScreenTitle = 'Modeless Test App';

class MainScreen extends StatelessWidget {
  const MainScreen({required this.machine, super.key});

  final NavigationMachine<S, E, T> machine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(mainAppScreenTitle)),
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              MyButton(machine: machine),
              TextButton(
                onPressed: () {
                  machine.fire(E.fwdC);
                },
                child: Text(
                  E.fwdC.toString(),
                ),
              ),
              TextButton(
                onPressed: () {
                  machine.fire(E.fwdD);
                },
                child: Text(
                  E.fwdD.toString(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({required this.machine, super.key});
  final NavigationMachine<S, E, T> machine;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        machine.fire(E.fwdB, context: context);
      },
      child: Text(E.fwdB.toString()),
    );
  }
}

const modelessBottomSheetText = 'ModelessBottomSheet';
const modalBottomSheetText = 'ModalBottomSheet';
const snackBarText = 'A SnackBar has been shown.';
const closeButtonTitle = 'Close this widget';

HismaRouterGenerator<S, E> createGenerator({
  required NavigationMachine<S, E, T> machine,
  required bool rootNavigator,
}) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<E, void>(
          widget: MainScreen(machine: machine),
        ),
        // S.b: PagelessCreator<E, void>(
        //   present: showTestDialog,
        //   rootNavigator: rootNavigator,
        //   machine: machine,
        //   event: E.back,
        // ),
        /* S.b: BottomSheetCreator(
          event: E.back,
          present: (context, close) {
            return showBottomSheet<void>(
              context: context!,
              builder: (context) => Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(modelessBottomSheetText),
                      ElevatedButton(
                        child: const Text(closeButtonTitle),
                        onPressed: () {
                          close();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),*/
        S.c: PagelessCreator<E, int>(
          rootNavigator: false,
          event: E.back,
          presenter: PresentModalBottomSheet(),
        ),
        S.d: SnackBarCreator(
          event: E.back,
          presenter: SnackBarPresenterTest(),
        ),
      },
    );

enum S { a, b, c, d }

enum E { fwdB, fwdC, fwdD, back }

enum T { toA, toB, toC, toD }

NavigationMachine<S, E, T> createMachine() => NavigationMachine<S, E, T>(
      initialStateId: S.a,
      events: E.values,
      name: 'bottomSheetMachine',
      states: {
        S.a: h.State(
          etm: {
            E.fwdB: [T.toB],
            E.fwdC: [T.toC],
            E.fwdD: [T.toD],
          },
        ),
        S.b: h.State(
          etm: {
            E.back: [T.toA],
          },
        ),
        S.c: h.State(
          etm: {
            E.back: [T.toA],
          },
        ),
        S.d: h.State(
          etm: {
            E.back: [T.toA],
          },
        ),
      },
      transitions: {
        T.toA: h.Transition(
          to: S.a,
          onAction: h.Action(
            description: 'print return value',
            action: (machine, dynamic arg) {
              // print('arg: $arg');
            },
          ),
        ),
        T.toB: h.Transition(to: S.b),
        T.toC: h.Transition(to: S.c),
        T.toD: h.Transition(to: S.d),
      },
    );

class PresentModalBottomSheet implements Presenter<int> {
  @override
  Future<int?> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<int> close,
    required dynamic arg,
  }) =>
      showModalBottomSheet<int>(
        context: context,
        builder: (context) => Container(
          height: 200,
          color: Colors.amber,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(modalBottomSheetText),
                ElevatedButton(
                  child: const Text(closeButtonTitle),
                  onPressed: () {
                    close(99);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

class SnackBarPresenterTest implements SnackBarPresenter {
  @override
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> present(
    BuildContext? context,
    ScaffoldMessengerState scaffoldMessengerState,
    Close<SnackBarClosedReason> close,
  ) =>
      scaffoldMessengerState.showSnackBar(
        SnackBar(
          content: const Text(snackBarText),
          action: SnackBarAction(
            label: closeButtonTitle,
            onPressed: () {
              close();
            },
          ),
        ),
      );
}
