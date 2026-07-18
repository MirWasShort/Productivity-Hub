import 'package:flutter/material.dart';

class SmartTodoApp extends StatelessWidget {
  const SmartTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart TODO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const Scaffold(
        body: Center(child: Text('Smart TODO')),
      ),
    );
  }
}
