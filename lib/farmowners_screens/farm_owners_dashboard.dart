import 'package:flutter/material.dart';
import '../sign_in_screen.dart'; // Import the SignInScreen
import 'manage_farm_workers_screen.dart'; // Import ManageFarmWorkersScreen
import 'manage_farm_data_screen.dart'; // Import ManageFarmDataScreen
import 'record_farm_progress_screen.dart'; // Import RecordFarmProgressScreen

class FarmOwnersDashboardScreen extends StatelessWidget {
  const FarmOwnersDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Owners Dashboard'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // Removes the go-back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navigate to SignInScreen upon sign-out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          DashboardCard(
            title: 'Add/Delete Workers',
            icon: Icons.group_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageFarmWorkersScreen(),
                ),
              );
            },
          ),
          DashboardCard(
            title: 'Manage Records',
            icon: Icons.folder,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageFarmDataScreen(),
                ),
              );
            },
          ),
          DashboardCard(
            title: 'View Progress',
            icon: Icons.trending_up,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordFarmProgressScreen(),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
