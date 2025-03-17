import 'package:flutter/material.dart';
import '../sign_in_screen.dart';
import 'record_task_screen.dart';
import 'farm_updates_screen.dart'; // Adjust the path if needed

class FarmWorkersDashboardScreen extends StatelessWidget {
  const FarmWorkersDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> cards = [
      DashboardItem(
        title: 'Record Task',
        subtitle: 'Log your daily activities',
        icon: Icons.edit_note,
        color: const Color(0xFF4CAF50),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecordTaskScreen()),
        ),
      ),
      DashboardItem(
        title: 'Notices',
        subtitle: 'View & Add important updates',
        icon: Icons.notifications_active,
        color: const Color(0xFFF44336),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FarmUpdatesScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false, // Removes the back arrow
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Farm Workers Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF43A047),
                      Color(0xFF1B5E20),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  // Navigate to the SignInScreen on sign-out
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => DashboardCard(
                  title: cards[index].title,
                  subtitle: cards[index].subtitle,
                  icon: cards[index].icon,
                  color: cards[index].color,
                  onTap: cards[index].onTap,
                ),
                childCount: cards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({super.key, 
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
