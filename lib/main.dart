import 'package:flutter/material.dart';
import 'package:tasks_manager/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Productivity Hub',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 64, 15, 128),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 85, 6, 84),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 45, 2, 48),
      ),
      home: const HomeScreen(),
    );
  }
}
