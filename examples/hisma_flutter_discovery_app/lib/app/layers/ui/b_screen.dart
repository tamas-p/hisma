import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../machine/app_machine.dart';

class BScreen extends ConsumerWidget {
  const BScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          // leading: BackButton(
          //   onPressed: () {
          //     ref.read(appMachineProvider).fire(E.backward);
          //   },
          // ),
          ),
      body: Column(
        children: [
          const Text('B Screen'),
          TextButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                initialDate: DateTime.now(),
                currentDate: DateTime.now(),
                lastDate: DateTime(2028),
              );

              print('# picked date: $pickedDate');
            },
            child: const Text('DatePickerDialog'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(appMachineProvider).fire(E.forward);
            },
            child: const Text('Forward'),
          ),
        ],
      ),
    );
  }
}
