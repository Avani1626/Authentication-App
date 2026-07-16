import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CalcApp());
}

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5CE7),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Calc',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true, colorScheme: scheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: scheme),
      home: Scaffold(
        appBar: AppBar(title: const Text('Calc')),
        body: const Center(child: Text('Coming soon')),
      ),
    );
  }
}
