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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Must select due date.')));
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save data: $error')));
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
                style: TextStyle(fontSize: 28),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  labelStyle: TextStyle(fontSize: 24),
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
              SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      style: TextStyle(fontSize: 28),
                      dropdownColor: const Color.fromARGB(255, 85, 6, 84),
                      initialValue: _selectedPriority,
                      icon: Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        label: Text(
                          'Task Priority',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      iconSize: 40,
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
                                  style: TextStyle(fontSize: 24, color: Colors.white),
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
                              ? 'Date is missing'
                              : formatter.format(_enteredDate!),
                          style: TextStyle(fontSize: 20),
                        ),
                        IconButton(
                          onPressed: _datePicker,
                          icon: Icon(Icons.calendar_month_outlined),
                          iconSize: 26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset', style: TextStyle(fontSize: 20)),
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
                            style: TextStyle(fontSize: 20),
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
