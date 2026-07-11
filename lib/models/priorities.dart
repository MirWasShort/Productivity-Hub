import 'package:flutter/material.dart';
import 'package:tasks_manager/models/prio.dart';

final priority = {
  Prios.high: Priority(
    numberPrio: 1,
    prio: 'high',
    icon: Icon(Icons.priority_high),
    color: Colors.red,
  ),
  Prios.medium: Priority(
    numberPrio: 2,
    prio: 'medium',
    icon: Icon(Icons.hourglass_bottom_rounded),
    color: Colors.orange,
  ),
  Prios.low: Priority(
    numberPrio: 3,
    prio: 'low',
    icon: Icon(Icons.hourglass_top_rounded),
    color: Colors.green,
  ),
};
