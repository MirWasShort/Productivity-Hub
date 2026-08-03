import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks_manager/models/priority_model.dart';
import 'package:tasks_manager/models/priorities.dart';

final formatter = DateFormat.yMd();

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
  DateTime? _enteredDate = DateTime.now();

  void _datePicker() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 5, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: lastDate,
    );

    setState(() {
      _enteredDate = selectedDate;
    });
  }

  void _submitTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_enteredDate == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una data di scadenza.')),
      );
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Only the priority *name* is stored — Priority itself holds an
      // Icon/Color and can't be serialized to Firestore.
      await FirebaseFirestore.instance.collection('Tasks').add({
        'name': _enteredName,
        'priority': _selectedPriority.prio,
        'date': Timestamp.fromDate(_enteredDate!),
        'userId': user.uid,
      });

      if (!mounted) return;
      // Closing the screen is enough: HomeScreen listens to the Firestore
      // stream in real time, so the new task will appear automatically.
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il salvataggio: $error')),
      );
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new task', style: TextStyle(fontSize: 30)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  label: Text(
                    'Task Description',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
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
                                  width: 24,
                                  height: 24,
                                  color: prio.value.color,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  prio.value.prio,
                                  style: TextStyle(fontSize: 18),
                                ),
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
                  SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _enteredDate == null
                              ? 'Due date is missing'
                              : formatter.format(_enteredDate!),
                          style: TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          onPressed: _datePicker,
                          icon: Icon(Icons.calendar_month_outlined),
                        ),
                      ],
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
                    child: const Text('Reset', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _submitTask,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            'Add Item',
                            style: TextStyle(fontSize: 16),
                          ),
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
