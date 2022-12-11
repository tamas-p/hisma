import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../machine/app_machine.dart';

class B1Screen extends ConsumerWidget {
  const B1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            ref.read(appMachineProvider).fire(E.backward);
          },
        ),
      ),
      body: Column(
        children: const [
          Text('B1 Screen'),
        ],
      ),
    );
  }
}
