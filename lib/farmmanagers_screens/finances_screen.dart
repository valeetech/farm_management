import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  _FinancesScreenState createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _transactionType = 'Revenue';

  Future<void> _addTransaction() async {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) return;

    try {
      double amount = double.parse(_amountController.text);
      await _firestore.collection('transactions').add({
        'description': _descriptionController.text,
        'amount': _transactionType == 'Expense' ? -amount : amount,
        'date': DateTime.now().toIso8601String(),
        'type': _transactionType,
      });

      _descriptionController.clear();
      _amountController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showAddTransactionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Transaction',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _transactionType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Transaction Type',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _transactionType = value!;
                      });
                    },
                    items: ['Revenue', 'Expense'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Transaction'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getTransactions() {
    return _firestore.collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  double _parseAmount(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.parse(value);
    }
    return 0.0;
  }

  Widget _buildFinancialOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!.docs;
        double revenue = 0;
        double expenses = 0;

        for (var transaction in transactions) {
          final amount = _parseAmount(transaction['amount']);
          if (amount > 0) {
            revenue += amount;
          } else {
            expenses += amount.abs();
          }
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Financial Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFinancialStat('Revenue', '\$${revenue.toStringAsFixed(2)}', Colors.green),
                    _buildFinancialStat('Expenses', '\$${expenses.toStringAsFixed(2)}', Colors.red),
                    _buildFinancialStat('Profit', '\$${(revenue - expenses).toStringAsFixed(2)}', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinancialStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _getTransactions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = snapshot.data!.docs;
            if (transactions.isEmpty) {
              return const Center(
                child: Text('No transactions yet'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionItem(
                  transaction['description'],
                  transaction['amount'],
                  transaction['date'],
                  transaction['type'],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String description, dynamic amount, String date, String type) {
    final double parsedAmount = _parseAmount(amount);
    DateTime transactionDate = DateTime.parse(date);
    String formattedDate = '${transactionDate.day}/${transactionDate.month}/${transactionDate.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: type == 'Revenue' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            type == 'Revenue' ? Icons.arrow_upward : Icons.arrow_downward,
            color: type == 'Revenue' ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formattedDate),
        trailing: Text(
          '\$${parsedAmount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: type == 'Revenue' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionForm,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialOverview(),
            const SizedBox(height: 24),
            _buildTransactionsSection(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}