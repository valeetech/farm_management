// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'plan_coordinate_screen.dart';
import 'budget_screen.dart';
import 'resources_screen.dart';
import 'compliance_screen.dart';
import 'finances_screen.dart';

class FarmManagersDashboardScreen extends StatelessWidget {
  const FarmManagersDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Managers Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [

          DashboardCard(
            title: 'Update Finances',
            icon: Icons.account_balance,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FinancesScreen(),
                ),
              );
            },
          ),
          DashboardCard(
            title: 'Set Budgets',
            icon: Icons.attach_money,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetScreen(),
                ),
              );
            },
          ),
          DashboardCard(
            title: 'Compliance Report',
            icon: Icons.report,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComplianceScreen(),
                ),
              );
            },
          ),
          DashboardCard(
            title: 'Plan & Coordinate',
            icon: Icons.schedule,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlanCoordinateScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({super.key, 
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}