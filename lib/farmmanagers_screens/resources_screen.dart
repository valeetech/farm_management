// lib/screens/resources_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  _ResourcesScreenState createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for form inputs
  TextEditingController equipmentController = TextEditingController();
  TextEditingController inventoryController = TextEditingController();
  TextEditingController workforceController = TextEditingController();

  // Methods to save data to Firestore
  Future<void> _saveResourceData(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Resources'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResourcesSummary(),
            const SizedBox(height: 24),
            _buildEquipmentSection(),
            const SizedBox(height: 24),
            _buildInventorySection(),
            const SizedBox(height: 24),
            _buildWorkforceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resources Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Equipment', '23 Units'),
                _buildSummaryItem('Inventory', '85% Full'),
                _buildSummaryItem('Workers', '28 Active'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildEquipmentItem('Tractors', 5, 3),
        _buildEquipmentItem('Harvesters', 3, 2),
        _buildEquipmentItem('Irrigation Systems', 8, 8),
        const SizedBox(height: 16),
        _buildAddEquipmentForm(),
      ],
    );
  }

  Widget _buildEquipmentItem(String name, int total, int inUse) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.agriculture),
        title: Text(name),
        subtitle: Text('In Use: $inUse / Total: $total'),
        trailing: Icon(
          inUse == total ? Icons.warning : Icons.check_circle,
          color: inUse == total ? Colors.orange : Colors.green,
        ),
      ),
    );
  }

  Widget _buildAddEquipmentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Add Equipment', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: equipmentController,
              decoration: const InputDecoration(
                labelText: 'Equipment Name',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (equipmentController.text.isNotEmpty) {
                  _saveResourceData('equipment', {
                    'name': equipmentController.text,
                    'total': 0,
                    'inUse': 0,
                  });
                  equipmentController.clear();
                }
              },
              child: const Text('Save Equipment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInventoryItem('Seeds', 80),
        _buildInventoryItem('Fertilizers', 65),
        _buildInventoryItem('Feed', 90),
        const SizedBox(height: 16),
        _buildAddInventoryForm(),
      ],
    );
  }

  Widget _buildInventoryItem(String item, int stockLevel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stockLevel / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                stockLevel < 30 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text('Stock Level: $stockLevel%'),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInventoryForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Add Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: inventoryController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (inventoryController.text.isNotEmpty) {
                  _saveResourceData('inventory', {
                    'item': inventoryController.text,
                    'stockLevel': 0,
                  });
                  inventoryController.clear();
                }
              },
              child: const Text('Save Inventory'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkforceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workforce',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildWorkerCategory('Field Workers', 15),
        _buildWorkerCategory('Equipment Operators', 8),
        _buildWorkerCategory('Supervisors', 5),
        const SizedBox(height: 16),
        _buildAddWorkerForm(),
      ],
    );
  }

  Widget _buildWorkerCategory(String category, int count) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(category),
        trailing: Chip(
          label: Text('$count'),
          backgroundColor: Colors.green,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAddWorkerForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Add Worker Category', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: workforceController,
              decoration: const InputDecoration(
                labelText: 'Worker Category Name',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (workforceController.text.isNotEmpty) {
                  _saveResourceData('workforce', {
                    'category': workforceController.text,
                    'count': 0,
                  });
                  workforceController.clear();
                }
              },
              child: const Text('Save Workforce'),
            ),
          ],
        ),
      ),
    );
  }
}
