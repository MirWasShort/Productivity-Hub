import 'package:flutter/material.dart';

enum Prios { high, medium, low }

class Priority {
  Priority({required this.numberPrio, required this.prio, required this.icon, required this.color});

  final int numberPrio;
  final String prio;
  final Icon icon;
  final Color color;
}
