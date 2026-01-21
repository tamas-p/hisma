import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart' as h;
import 'package:hisma_flutter/hisma_flutter.dart';

import 'ui.dart';

void main() {
  runApp(DrawerApp());
}

class DrawerApp extends StatelessWidget {
  DrawerApp({super.key});
  final machine = createDrawerMachine()..start();
  late final gen = getDrawerRouterDelegator(machine);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: gen.routerDelegate,
    );
  }
}

enum DS { a, b, c }

enum DE { forward, backward }

enum DT { toB, toC, toA }

NavigationMachine<DS, DE, DT> createDrawerMachine() =>
    NavigationMachine<DS, DE, DT>(
      initialStateId: DS.a,
      name: 'Drawer Test',
      states: {
        DS.a: h.State(
          etm: {
            DE.forward: [DT.toB],
          },
        ),
        DS.b: h.State(
          etm: {
            DE.forward: [DT.toC],
            DE.backward: [DT.toA],
          },
        ),
        DS.c: h.State(
          etm: {
            DE.backward: [DT.toB],
          },
        ),
      },
      transitions: {
        DT.toA: h.Transition<DS>(to: DS.a),
        DT.toC: h.Transition<DS>(to: DS.c),
        DT.toB: h.Transition<DS>(to: DS.b),
      },
    );

HismaRouterGenerator<DS, DE> getDrawerRouterDelegator(
  NavigationMachine<DS, DE, DT> machine,
) =>
    HismaRouterGenerator(
      machine: machine,
      mapping: {
        DS.a: MaterialPageCreator<DE, void>(
          widget: Screen(
            machine,
            drawer: getDrawer(),
            extra: Builder(
              builder: (context) {
                return const BottomSheetButton();
              },
            ),
          ),
        ),
        DS.b: MaterialPageCreator<DE, void>(
          widget: Screen(
            machine,
            drawer: getDrawer(),
          ),
          event: DE.backward,
        ),
        DS.c: MaterialPageCreator<DE, void>(
          widget: Screen(
            machine,
            drawer: getDrawer(),
          ),
          event: DE.backward,
        ),
      },
    );

const drawerTitle = 'Drawer Header';

Widget getDrawer() => Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              drawerTitle,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
      ),
    );

class BottomSheetButton extends StatelessWidget {
  const BottomSheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return const TestBottomSheet();
              },
            );
          },
          child: const Text('Show Modal Bottom Sheet'),
        ),
        TextButton(
          onPressed: () {
            showBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return const TestBottomSheet();
              },
            );
          },
          child: const Text('Show Modeless Bottom Sheet'),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Text('This is a SnackBar'),
                  ],
                ),
                action: SnackBarAction(
                  label: 'Close',
                  onPressed: () {},
                ),
                duration: const Duration(seconds: 100),
              ),
            );
          },
          child: const Text('Show SnackBar'),
        ),
      ],
    );
  }
}

class TestBottomSheet extends StatelessWidget {
  const TestBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.amber,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('This is a bottom sheet'),
            ElevatedButton(
              child: const Text('Close Bottom Sheet'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
