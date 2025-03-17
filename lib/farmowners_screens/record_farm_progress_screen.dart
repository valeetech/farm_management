import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: RecordFarmProgressScreen(),
  ));
}

class RecordFarmProgressScreen extends StatefulWidget {
  const RecordFarmProgressScreen({super.key});

  @override
  _RecordFarmProgressScreenState createState() => _RecordFarmProgressScreenState();
}

class _RecordFarmProgressScreenState extends State<RecordFarmProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _statusController = TextEditingController();
  final _notesController = TextEditingController();
  bool _showForm = false;

  final CollectionReference farmProgressCollection =
  FirebaseFirestore.instance.collection('farm_progress');

  void _submitProgress() async {
    if (_formKey.currentState?.validate() ?? false) {
      final date = _dateController.text;
      final status = _statusController.text;
      final notes = _notesController.text;

      await farmProgressCollection.add({
        'date': date,
        'status': status,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Farm progress for $date recorded successfully!')),
      );

      _dateController.clear();
      _statusController.clear();
      _notesController.clear();

      setState(() {
        _showForm = false;
      });
    }
  }

  Stream<List<Map<String, dynamic>>> _getFarmProgress() {
    return farmProgressCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Farm Progress Records'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = !_showForm;
          });
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: Icon(_showForm ? Icons.close : Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showForm ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showForm ? 1.0 : 0.0,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Add New Progress Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                hintText: 'Enter the date of progress',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter the date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _statusController,
                              decoration: InputDecoration(
                                labelText: 'Progress Status',
                                hintText: 'Enter progress status',
                                prefixIcon: const Icon(Icons.timeline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter the progress status';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                hintText: 'Enter additional notes about progress',
                                prefixIcon: const Icon(Icons.notes),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter some notes';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitProgress,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Submit Progress",
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

              // Records List
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getFarmProgress(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final progressRecords = snapshot.data ?? [];

                  if (progressRecords.isEmpty) {
                    return Center(
                      child: Text(
                        'No records yet. Tap + to add a new record.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: progressRecords.length,
                    itemBuilder: (context, index) {
                      final record = progressRecords[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Date: ${record['date']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Status: ${record['status']}'),
                              const SizedBox(height: 4),
                              Text('Notes: ${record['notes']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}