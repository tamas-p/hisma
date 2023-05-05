// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as hisma;
import 'package:hisma/hisma.dart';
import 'package:hisma_flutter/hisma_flutter.dart';
import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:logging/logging.dart';

import 'utils.dart';

enum AS { signedIn, signedOut }

enum AE { signIn, signOut }

enum AT { toSignedIn, toSignedOut }

final authMachine = StateMachineWithChangeNotifier<AS, AE, AT>(
  events: AE.values,
  name: 'authMachine',
  initialStateId: AS.signedOut,
  states: {
    AS.signedOut: hisma.State(
      etm: {
        AE.signIn: [AT.toSignedIn],
      },
    ),
    AS.signedIn: hisma.State(
      etm: {
        AE.signOut: [AT.toSignedOut],
      },
      regions: [
        hisma.Region<AS, AE, AT, S>(machine: machine),
      ],
    ),
  },
  transitions: {
    AT.toSignedOut: hisma.Transition(to: AS.signedOut),
    AT.toSignedIn: hisma.Transition(to: AS.signedIn),
  },
);

//------------------------------------------------------------------------------

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoginScreen')),
      body: createButtonsFromStates([authMachine.states[AS.signedOut]]),
    );
  }
}

//------------------------------------------------------------------------------

final authRouterGenerator = HismaRouterGenerator<AS, Widget, AE>(
  machine: authMachine,
  mapping: {
    AS.signedOut: MaterialPageCreator<AS>(widget: const LoginScreen()),
    AS.signedIn: MaterialPageCreator<AS>(
      widget: Router(routerDelegate: hismaRouterGenerator.routerDelegate),
    ),
  },
);

//==============================================================================

enum S { a, b, b1, b2, c, c1 }

enum E { forward, show, fetch, backward, jump }

enum T { toA, toB, toB1, toB2, toBFromB2, toC, toC1 }

final machine = StateMachineWithChangeNotifier<S, E, T>(
  events: E.values,
  initialStateId: S.a,
  name: 'machine',
  history: HistoryLevel.deep,
  states: {
    S.a: hisma.State(
      etm: {
        E.forward: [T.toB],
      },
    ),
    S.b: hisma.State(
      etm: {
        E.forward: [T.toC],
        E.backward: [T.toA],
        E.show: [T.toB1],
        E.fetch: [T.toB2],
      },
      onEntry: getAction(),
    ),
    S.b1: hisma.State(
      etm: {
        E.backward: [T.toB],
      },
    ),
    S.b2: hisma.State(
      etm: {
        E.backward: [T.toBFromB2],
      },
      onEntry: hisma.Action(
        description: 'Fetch weather report.',
        action: (machine, dynamic arg) async {
          Future<void>.delayed(const Duration(seconds: 1), () {
            print('Weather data is fetched.');
            machine.fire(E.backward, arg: 'Sunny weather.');
          });
        },
      ),
    ),
    S.c: hisma.State(
      etm: {
        E.backward: [T.toB],
        E.show: [T.toC1],
      },
      onEntry: getAction(),
    ),
    S.c1: hisma.State(
      etm: {
        E.backward: [T.toC],
        E.jump: [T.toA],
      },
    ),
  },
  transitions: {
    T.toA: hisma.Transition(to: S.a),
    T.toB: hisma.Transition(to: S.b),
    T.toB1: hisma.Transition(to: S.b1),
    T.toB2: hisma.Transition(to: S.b2),
    T.toBFromB2: hisma.Transition(
      to: S.b,
      onAction: hisma.Action(
        description: 'Weather info received.',
        action: (machine, dynamic arg) async {
          print('Weather info received: $arg');
        },
      ),
    ),
    T.toC: hisma.Transition(to: S.c),
    T.toC1: hisma.Transition(to: S.c1),
  },
);

hisma.Action getAction() => hisma.Action(
      description: 'Print out data passed.',
      action: (machine, dynamic arg) async => print('Arg passed: $arg'),
    );

//------------------------------------------------------------------------------

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScreenA')),
      body: createButtonsFromStates([
        authMachine.states[AS.signedIn],
        machine.states[S.a],
      ]),
    );
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScreenB')),
      body: createButtonsFromStates([
        authMachine.states[AS.signedIn],
        machine.states[S.b],
      ]),
    );
  }
}

class DialogPagelessRouteManager<T> implements PagelessRouteManager<T> {
  DialogPagelessRouteManager({required this.title, required this.text});

  final String title;
  final String text;
  BuildContext? _context;

  @override
  Future<T?> open(BuildContext context) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        _context = context;
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(text)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                close();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void close([T? value]) {
    final context = _context;
    if (context != null) Navigator.of(context).pop();
  }
}

class ScreenC extends StatelessWidget {
  const ScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScreenC')),
      body: Column(
        children: [
          createButtonsFromStates(
            [
              authMachine.states[AS.signedIn],
              machine.states[S.c],
            ],
          ),
          TextButton(
            onPressed: () {
              print('OPEN');
              showDatePicker(
                context: context,
                firstDate: DateTime(2021),
                initialDate: DateTime.now(),
                currentDate: DateTime.now(),
                lastDate: DateTime(2028),
              );
            },
            child: const Text('OPEN'),
          ),
        ],
      ),
    );
  }
}

class DatePickerPagelessRouteManager implements PagelessRouteManager<DateTime> {
  BuildContext? _context;
  @override
  Future<DateTime?> open(BuildContext context) {
    _context = context;
    return showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      initialDate: DateTime.now(),
      currentDate: DateTime.now(),
      lastDate: DateTime(2028),
    );
  }

  @override
  void close([DateTime? value]) {
    final context = _context;
    if (context != null) Navigator.of(context, rootNavigator: true).pop();
  }
}

class SnackbarPagelessRouteManager
    implements PagelessRouteManager<SnackBarClosedReason> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? ret;

  @override
  Future<SnackBarClosedReason> open(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('Hi, I am a SnackBar!'),
      backgroundColor: Colors.black12,
      duration: const Duration(seconds: 10),
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

//------------------------------------------------------------------------------

final hismaRouterGenerator = HismaRouterGenerator<S, Widget, E>(
  machine: machine,
  mapping: {
    S.a: MaterialPageCreator<S>(widget: const ScreenA()),
    S.b: OverlayMaterialPageCreator<S, E>(
      widget: const ScreenB(),
      event: E.backward,
    ),
    S.b1: PagelessCreator<void, E>(
      event: E.backward,
      pagelessRouteManager:
          DialogPagelessRouteManager(title: 'title b1', text: 'text b1'),
    ),
    S.b2: NoUIChange(),
    S.c: OverlayMaterialPageCreator<S, E>(
      widget: const ScreenC(),
      event: E.backward,
    ),
    S.c1: PagelessCreator<void, E>(
      event: E.backward,
      // pagelessRouteManager: DatePickerPagelessRouteManager(),
      pagelessRouteManager: SnackbarPagelessRouteManager(),
    ),
  },
);

//------------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: authRouterGenerator.routerDelegate,
      routeInformationParser: authRouterGenerator.routeInformationParser,
    );
  }
}

//------------------------------------------------------------------------------

Future<void> main() async {
  initLogging();

  hisma.StateMachine.monitorCreators = [
    (m) => VisualMonitor(m, host: '192.168.122.1'),
  ];

  await authMachine.start();
  runApp(const MyApp());
}

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.OFF;
  // Logger(vismaMonitorName).level = Level.INFO;
  Logger('hisma_flutter').level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
}
