import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _spentController = TextEditingController();

  double _parseAmount(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Budget Manager',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.black87),
            onPressed: () {
              // Theme switching functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBudgetOverview(),
            const SizedBox(height: 24),
            _buildBudgetCategories(),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(16),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddCategoryDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Budget'),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBudgetOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('budget_categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalBudget = 0;
        double totalSpent = 0;

        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          totalBudget += _parseAmount(data['total']);
          totalSpent += _parseAmount(data['spent']);
        }

        double remaining = totalBudget - totalSpent;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Budget Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOverviewItem('Total Budget', totalBudget),
                  _buildOverviewItem('Spent', totalSpent),
                  _buildOverviewItem('Remaining', remaining),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewItem(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('budget_categories').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No budget categories added yet'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return _buildCategoryCard(
                  doc.id,
                  data['category'] ?? '',
                  _parseAmount(data['total']),
                  _parseAmount(data['spent']),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String docId, String category, double total, double spent) {
    double progress = total > 0 ? spent / total : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditCategoryDialog(
                        context,
                        docId,
                        category,
                        total,
                        spent,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(context, docId),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                progress > 0.9 ? Colors.red : Colors.green,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${spent.toStringAsFixed(2)} spent'),
                Text('\$${total.toStringAsFixed(2)} total'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    _categoryController.clear();
    _totalController.clear();
    _spentController.clear();
    await _showDialog(context);
  }

  Future<void> _showEditCategoryDialog(
      BuildContext context,
      String docId,
      String category,
      double total,
      double spent,
      ) async {
    _categoryController.text = category;
    _totalController.text = total.toString();
    _spentController.text = spent.toString();
    await _showDialog(context, docId: docId);
  }

  Future<void> _showDialog(BuildContext context, {String? docId}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add Budget Category' : 'Edit Budget Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: 'Total Budget',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _spentController,
              decoration: const InputDecoration(
                labelText: 'Amount Spent',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveBudgetCategory(context, docId),
            child: Text(docId == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBudgetCategory(BuildContext context, String? docId) async {
    try {
      final category = _categoryController.text.trim();
      final total = double.parse(_totalController.text);
      final spent = double.parse(_spentController.text);

      if (category.isEmpty) {
        throw 'Please enter a category name';
      }

      if (total <= 0) {
        throw 'Total budget must be greater than 0';
      }

      if (spent < 0) {
        throw 'Spent amount cannot be negative';
      }

      final data = {
        'category': category,
        'total': total,
        'spent': spent,
      };

      if (docId == null) {
        await FirebaseFirestore.instance.collection('budget_categories').add(data);
      } else {
        await FirebaseFirestore.instance.collection('budget_categories').doc(docId).update(data);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteCategory(BuildContext context, String docId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this budget category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('budget_categories')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _totalController.dispose();
    _spentController.dispose();
    super.dispose();
  }
}