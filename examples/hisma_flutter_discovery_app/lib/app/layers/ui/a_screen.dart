import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../machine/app_machine.dart';

class AScreen extends ConsumerWidget {
  const AScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text('A Screen'),
          ElevatedButton(
            onPressed: () {
              ref.read(appMachineProvider).fire(E.forward);
            },
            child: const Text('Forward'),
          ),
        ],
      ),
    );
  }
}
