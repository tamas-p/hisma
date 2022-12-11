import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../components/comp_a/layers/router/a_comp_router_provider.dart';
import '../../components/comp_f/layers/router/f_comp_router_provider.dart';
import '../machine/app_machine.dart';
import '../ui/b1_screen.dart';
import '../ui/b_screen.dart';
import '../ui/e_screen.dart';

class StatelessScreen extends StatelessWidget {
  const StatelessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('-------------------- StatelessScreen BUILD ----------------------');
    return Scaffold(
      appBar: AppBar(title: const Text('StatelessScreen')),
    );
  }
}

class StatefulScreen extends StatefulWidget {
  const StatefulScreen({super.key});

  @override
  State<StatefulScreen> createState() => _StatefulScreenState();
}

class _StatefulScreenState extends State<StatefulScreen> {
  int state = 0;

  @override
  Widget build(BuildContext context) {
    print('-------------------- StatefulScreen BUILD ----------------------');
    return Scaffold(
      appBar: AppBar(title: const Text('StatefulScreen')),
    );
  }
}

final appRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, Widget, E>(
    machine: ref.read(appMachineProvider),
    creators: {
      // S.a: MaterialPageCreator<S>(widget: const AScreen()),
      S.a: MaterialPageCreator<S>(
        // widget: const StatelessScreen(),
        // widget: const StatefulScreen(),
        widget:
            Router(routerDelegate: ref.read(aRouterProvider).routerDelegate),
      ),
      S.a1: PagelessCreator<E, bool?>(
        show: (context) {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Problem during login'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[
                      Text('Hello'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        },
        event: E.backward,
      ),
      S.b: OverlayMaterialPageCreator<S, E>(
        widget: const BScreen(),
        event: E.backward,
      ),
      S.b1: OverlayMaterialPageCreator<S, E>(
        widget: const B1Screen(),
        event: E.backward,
      ),
      S.c: PagelessCreator<E, DateTime?>(
        show: (context) => showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          initialDate: DateTime.now(),
          currentDate: DateTime.now(),
          lastDate: DateTime(2028),
        ),
        event: E.forward,
      ),
      S.d: PagelessCreator<E, bool?>(
        show: (context) => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Problem during login'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('Hello'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ),
        event: E.backward,
      ),
      S.e: OverlayMaterialPageCreator<S, E>(
        // S.e: MaterialPageCreator<S>(
        widget: const EScreen(),
        event: E.jump,
      ),
      S.f: MaterialPageCreator<S>(
        widget:
            Router(routerDelegate: ref.read(fRouterProvider).routerDelegate),
      ),
    },
  ),
);
