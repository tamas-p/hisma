import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EScreen extends ConsumerWidget {
  const EScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text('E Screen'),
          TextButton(
            onPressed: () {
              print('pop!');
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              Navigator.popUntil(context, ModalRoute.withName('S.b'));
            },
            child: const Text('pop!'),
          ),
        ],
      ),
    );
  }
}
