import 'package:flutter/material.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calc',
      home: Scaffold(
        appBar: AppBar(title: const Text('Calc')),
        body: const Center(child: Text('Coming soon')),
      ),
    );
  }
}
