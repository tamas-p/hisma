import 'package:flutter/material.dart';

class CompAScreenA extends StatelessWidget {
  const CompAScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: const [
          Text('CompA - ScreenA'),
        ],
      ),
    );
  }
}
