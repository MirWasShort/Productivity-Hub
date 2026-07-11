import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasks_manager/models/task.dart';
import 'package:tasks_manager/models/prio.dart';
import 'package:tasks_manager/models/priorities.dart';
import 'package:http/http.dart' as http;

class NewTask extends StatefulWidget {
  const NewTask({super.key});

  @override
  State<NewTask> createState() {
    return _NewTaskState();
  }
}

class _NewTaskState extends State<NewTask> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _selectedPriority = priority[Prios.high]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
        'taskmanager-52bed-default-rtdb.europe-west1.firebasedatabase.app',
        'task-manager.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _enteredName,
          'priority': _selectedPriority.prio,
        }),
      );
      final Map<String, dynamic> resData = jsonDecode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        Task(
          id: resData['name'],
          name: _enteredName,
          priority: _selectedPriority,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new task')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Task Description')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedPriority,
                      items: [
                        for (final prio in priority.entries)
                          DropdownMenuItem(
                            value: prio.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: prio.value.color,
                                ),
                                const SizedBox(width: 10),
                                Text(prio.value.prio),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
