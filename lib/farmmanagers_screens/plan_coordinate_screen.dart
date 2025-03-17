// lib/screens/plan_coordinate_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanCoordinateScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 PlanCoordinateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan & Coordinate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Tasks Overview'),
            _buildTaskList(),
            _buildSection('Schedule'),
            _buildCalendar(),
            _buildSection('Team Coordination'),
            _buildTeamList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs;

        return Column(
          children: tasks.map((doc) => _buildTaskItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildTaskItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final task = data['task'] ?? '';
    final time = data['time'] ?? '';
    final isCompleted = data['isCompleted'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.pending,
          color: isCompleted ? Colors.green : Colors.orange,
        ),
        title: Text(task),
        subtitle: Text(time),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _firestore.collection('tasks').doc(doc.id).delete(),
        ),
        onTap: () => _firestore
            .collection('tasks')
            .doc(doc.id)
            .update({'isCompleted': !isCompleted}),
      ),
    );
  }

  Widget _buildCalendar() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Add your calendar widget or Firestore-based schedule here
            Text('Calendar View Coming Soon'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('team').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data!.docs;

        return Column(
          children: members.map((doc) => _buildTeamMember(doc)).toList(),
        );
      },
    );
  }

  Widget _buildTeamMember(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? '';
    final role = data['role'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(name.isNotEmpty ? name[0] : ''),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _firestore.collection('team').doc(doc.id).delete(),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: 'Task'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final task = taskController.text.trim();
                final time = timeController.text.trim();

                if (task.isNotEmpty && time.isNotEmpty) {
                  _firestore.collection('tasks').add({
                    'task': task,
                    'time': time,
                    'isCompleted': false,
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
