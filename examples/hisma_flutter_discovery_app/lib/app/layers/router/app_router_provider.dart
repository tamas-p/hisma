import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../utility/pageless_route_helper.dart';
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
  (ref) => HismaRouterGenerator<S, E>(
    machine: ref.read(appMachineProvider),
    mapping: {
      // S.a: MaterialPageCreator<S>(widget: const AScreen()),
      S.a: MaterialPageCreator<E, void>(
        // widget: const StatelessScreen(),
        // widget: const StatefulScreen(),
        widget:
            Router(routerDelegate: ref.read(aRouterProvider).routerDelegate),
      ),
      S.a1: PagelessCreator<E, void>(
        event: E.backward,
        presenter: PresentDialogLogin(),
        rootNavigator: true,
      ),
      S.b: MaterialPageCreator<E, void>(
        widget: const BScreen(),
        event: E.backward,
        overlay: true,
      ),
      S.b1: MaterialPageCreator<E, void>(
        widget: const B1Screen(),
        event: E.backward,
        overlay: true,
      ),
      S.c: PagelessCreator<E, DateTime>(
        event: E.backward,
        presenter: PresentDatePicker(),
        rootNavigator: true,
      ),
      S.d: PagelessCreator<E, void>(
        event: E.backward,
        presenter: PresentDialogLogin2(),
        rootNavigator: true,
      ),
      S.e: MaterialPageCreator<E, void>(
        // S.e: MaterialPageCreator<S>(
        widget: const EScreen(),
        overlay: true,
        event: E.backward,
      ),
      S.f: MaterialPageCreator<E, void>(
        overlay: true,
        widget:
            Router(routerDelegate: ref.read(fRouterProvider).routerDelegate),
      ),
    },
  ),
);

class PresentDialogLogin2 implements Presenter<void> {
  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<void> close,
    required dynamic fireArg,
  }) =>
      generateDialog<E, void>(
        context: context,
        rootNavigator: rootNavigator,
        title: 'Problem during login2',
        text: 'Hello2.',
      );
}

class PresentDatePicker implements Presenter<DateTime> {
  @override
  Future<DateTime?> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<DateTime> close,
    required dynamic fireArg,
  }) =>
      generateDatePicker<E>(
        context: context,
        rootNavigator: rootNavigator,
      );
}

class PresentDialogLogin implements Presenter<void> {
  @override
  Future<void> present({
    required BuildContext context,
    required bool rootNavigator,
    required Close<void> close,
    required dynamic fireArg,
  }) =>
      generateDialog<E, void>(
        context: context,
        rootNavigator: rootNavigator,
        title: 'Problem during login',
        text: 'Hello.',
      );
}
