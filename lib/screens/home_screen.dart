import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasks_manager/models/task.dart';
import 'package:tasks_manager/widgets/new_task.dart';
import 'package:tasks_manager/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sortByPriority = false;

  void _addItem() {
    // the StreamBuilder below listens
    // to Firestore in real time, so the new task shows up automatically
    // as soon as NewTask saves it.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => const NewTask()));
  }

  Future<void> _removeItem(Task item) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tasks')
          .doc(item.id)
          .delete();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete task.')),
      );
    }
  }

  void _toggleSort() {
    setState(() {
      _sortByPriority = !_sortByPriority;
    });
  }

  void _openSearch() {
    showSearch(context: context, delegate: TaskSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final content = StreamBuilder<QuerySnapshot>(
      // Filtered by userID
      // without this, every signed-in user would see (and could delete) everyone else's tasks.
      stream: FirebaseFirestore.instance
          .collection('Tasks')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (ctx, tskSnapshots) {
        if (tskSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (tskSnapshots.hasError) {
          return const Center(child: Text('Failed loading tasks.'));
        }
        if (!tskSnapshots.hasData || tskSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No tasks added yet',
              textScaler: TextScaler.linear(2.5),
            ),
          );
        }

        final tasks = tskSnapshots.data!.docs
            .map(
              (doc) => Task.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();

        if (_sortByPriority) {
          tasks.sort((a, b) {
            final prioComparison = a.priority.numberPrio.compareTo(
              b.priority.numberPrio,
            );
            if (prioComparison == 0) {
              return a.name.compareTo(b.name);
            }
            return prioComparison;
          });
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (ctx, index) {
            final task = tasks[index];
            return Dismissible(
              key: ValueKey(task.id),
              onDismissed: (direction) => _removeItem(task),
              background: Container(color: Colors.red),
              child: ListTile(
                title: Text(task.name, style: const TextStyle(fontSize: 24)),
                subtitle: Text(task.formattedDate),
                leading: Container(
                  width: 28,
                  height: 28,
                  color: task.priority.color,
                ),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks Manager',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
            iconSize: 34,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 85, 6, 84),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BottomAppBar(
            color: const Color.fromARGB(255, 85, 6, 84),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  iconSize: 30,
                ),
                SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: _openSearch,
                  icon: Icon(Icons.search),
                  label: Text(' Search '),
                  style: ButtonStyle(
                    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 28)),
                    iconSize: WidgetStatePropertyAll(30),
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(230, 115, 18, 114),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                IconButton(
                  onPressed: _toggleSort,
                  icon: Icon(
                    _sortByPriority ? Icons.sort : Icons.sort_outlined,
                  ),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ),
      ),
      body: content,
    );
  }
}
