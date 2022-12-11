import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FScreen extends ConsumerWidget {
  const FScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text('F Screen'),
          TextButton(
            onPressed: () {},
            child: const Text('action'),
          ),
        ],
      ),
    );
  }
}
