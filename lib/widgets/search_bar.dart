import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasks_manager/models/task.dart';

class TaskSearchDelegate extends SearchDelegate<void> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Tasks')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tasks = snapshot.data!.docs
            .map(
              (doc) => Task.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .where(
              (task) => task.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

        if (tasks.isEmpty) {
          return const Center(child: Text('No items found.'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (ctx, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(task.name),
              subtitle: Text(task.formattedDate),
              leading: Container(
                width: 24,
                height: 24,
                color: task.priority.color,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildTaskList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildTaskList(context);
}
