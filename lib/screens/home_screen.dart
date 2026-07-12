import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasks_manager/models/priorities.dart';
import 'package:tasks_manager/models/task.dart';
import 'package:tasks_manager/widgets/new_task.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _currentTasks = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'taskmanager-52bed-default-rtdb.europe-west1.firebasedatabase.app',
      'task-manager.json',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = jsonDecode(response.body);

      final List<Task> loadedItemsList = [];
      for (final item in listData.entries) {
        final prio = priority.entries
            .firstWhere((tsk) => tsk.value.prio == item.value['priority'])
            .value;
        loadedItemsList.add(
          Task(id: item.key, name: item.value['name'], priority: prio),
        );
      }
      final sortedList = loadedItemsList;
      setState(() {
        sortedList.sort((a, b) {
          int prioComparison = a.priority.numberPrio.compareTo(
            b.priority.numberPrio,
          );
          if (prioComparison == 0) {
            return a.name.compareTo(b.name);
          }
          return prioComparison;
        });
        _currentTasks = sortedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<Task>(MaterialPageRoute(builder: (ctx) => const NewTask()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _currentTasks.add(newItem);
    });
  }

  void _removeItem(Task item) async {
    final index = _currentTasks.indexOf(item);
    setState(() {
      _currentTasks.remove(item);
    });
    final url = Uri.https(
      'taskmanager-52bed-default-rtdb.europe-west1.firebasedatabase.app',
      'task-manager.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _currentTasks.insert(index, item);
      });
    }
  }

  void _sortItems() async {
    if (_currentTasks.isEmpty) {
      return;
    }
    final sortedTasks = _currentTasks;

    sortedTasks.sort((a, b) {
      int prioComparison = a.priority.numberPrio.compareTo(
        b.priority.numberPrio,
      );
      if (prioComparison == 0) {
        return a.name.compareTo(b.name);
      }
      return prioComparison;
    });

    final url = Uri.https(
      'taskmanager-52bed-default-rtdb.europe-west1.firebasedatabase.app',
      'task-manager.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      return;
    }

    setState(() {
      _currentTasks = sortedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: const Text('No tasks added yet', textScaler: TextScaler.linear(2.5),));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_currentTasks.isNotEmpty) {
      content = ListView.builder(
        itemCount: _currentTasks.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_currentTasks[index]);
          },
          key: ValueKey(_currentTasks[index].id),
          child: ListTile(
            title: Text(_currentTasks[index].name, style: TextStyle(fontSize: 24)),
            leading: Container(
              width: 28,
              height: 28,
              color: _currentTasks[index].priority.color,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks', style: TextStyle(fontSize: 34)),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add), iconSize: 34,),
          IconButton(onPressed: _sortItems, icon: const Icon(Icons.sort), iconSize: 34),
        ],
      ),
      body: content,
    );
  }
}
