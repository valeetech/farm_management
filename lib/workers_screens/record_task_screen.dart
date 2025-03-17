import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecordTaskScreen extends StatefulWidget {
  const RecordTaskScreen({super.key});

  @override
  _RecordTaskScreenState createState() => _RecordTaskScreenState();
}

class _RecordTaskScreenState extends State<RecordTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskType = 'Harvesting';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  bool _showForm = false;

  Future<void> _saveTask() async {
    try {
      await FirebaseFirestore.instance.collection('farmTasks').add({
        'taskType': _taskType,
        'description': _description,
        'date': _selectedDate.toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task recorded successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _showForm = false;
        _description = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchTasks() {
    return FirebaseFirestore.instance
        .collection('farmTasks')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Tasks'),
        backgroundColor: const Color(0xFF43A047),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showForm = !_showForm),
        backgroundColor: const Color(0xFF43A047),
        child: Icon(_showForm ? Icons.close : Icons.add),
      ),
      body: Stack(
        children: [
          // Tasks List
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fetchTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tasks recorded yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final task = snapshot.data![index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF43A047).withOpacity(0.2),
                        child: Icon(
                          _getTaskIcon(task['taskType']),
                          color: const Color(0xFF43A047),
                        ),
                      ),
                      title: Text(
                        task['taskType'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(task['description']),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${DateTime.parse(task['date']).toLocal().toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Form Overlay
          if (_showForm)
            Container(
              color: Colors.black54,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'New Task',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Task Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                prefixIcon: const Icon(Icons.category),
                              ),
                              value: _taskType,
                              items: ['Harvesting', 'Planting', 'Irrigation', 'Fertilizing']
                                  .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _taskType = value!);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                prefixIcon: const Icon(Icons.description),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter task description';
                                }
                                return null;
                              },
                              onChanged: (value) => _description = value,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF43A047),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _saveTask();
                                }
                              },
                              child: const Text(
                                'Save Task',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'Harvesting':
        return Icons.agriculture;
      case 'Planting':
        return Icons.local_florist;
      case 'Irrigation':
        return Icons.water_drop;
      case 'Fertilizing':
        return Icons.grass;
      default:
        return Icons.work;
    }
  }
}