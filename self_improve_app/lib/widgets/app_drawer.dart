import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/reports_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'LifeLens AI',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Personal Life Assistant',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),

          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
              );
            },
          ),

          // Budget
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Budget & Expenses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
          ),

          // Goals
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Goals Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalsScreen()),
              );
            },
          ),

          // Activity
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Productivity & Activity'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityScreen()),
              );
            },
          ),

          // Insights
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('AI Insights'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsightsScreen()),
              );
            },
          ),

          const Divider(),

          // Statistics
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),

          // Reports
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),

          const Divider(),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Settings screen
            },
          ),

          // Backup & Restore
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Restore'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Backup screen
            },
          ),

          // Export Data
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Data'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement export functionality
            },
          ),

          // Help & Support
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Help screen
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About LifeLens AI'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'LifeLens AI',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.lightbulb,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'Your personal offline life management assistant. '
          'Track finances, goals, productivity, and skills all in one place. '
          'All your data stays private on your device.',
        ),
      ],
    );
  }
}
