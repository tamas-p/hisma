import 'package:flutter/material.dart';

class CompAScreenB extends StatelessWidget {
  const CompAScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: const [
          Text('CompA - ScreenB'),
        ],
      ),
    );
  }
}
