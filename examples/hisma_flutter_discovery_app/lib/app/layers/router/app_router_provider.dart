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
      S.a: MaterialPageCreator<void, S, E>(
        // widget: const StatelessScreen(),
        // widget: const StatefulScreen(),
        widget:
            Router(routerDelegate: ref.read(aRouterProvider).routerDelegate),
      ),
      S.a1: DialogCreator<void, E>(
        useRootNavigator: true,
        event: E.backward,
        show: (dc, context) => generateDialog<void, E>(
          dc: dc,
          context: context,
          title: 'Problem during login',
          text: 'Hello.',
        ),
      ),
      S.b: MaterialPageCreator<void, S, E>(
        widget: const BScreen(),
        event: E.backward,
        overlay: true,
      ),
      S.b1: MaterialPageCreator<void, S, E>(
        widget: const B1Screen(),
        event: E.backward,
        overlay: true,
      ),
      S.c: DialogCreator<DateTime, E>(
        useRootNavigator: true,
        event: E.forward,
        show: (dc, context) => generateDatePicker<E>(
          dc,
          context,
        ),
      ),
      S.d: DialogCreator<void, E>(
        useRootNavigator: true,
        event: E.backward,
        show: (dc, context) => generateDialog<void, E>(
          dc: dc,
          context: context,
          title: 'Problem during login2',
          text: 'Hello2.',
        ),
      ),
      S.e: MaterialPageCreator<void, S, E>(
        // S.e: MaterialPageCreator<S>(
        widget: const EScreen(),
        event: E.jump,
      ),
      S.f: MaterialPageCreator<void, S, E>(
        widget:
            Router(routerDelegate: ref.read(fRouterProvider).routerDelegate),
      ),
    },
  ),
);
