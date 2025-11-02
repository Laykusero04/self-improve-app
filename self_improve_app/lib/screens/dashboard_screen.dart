import 'package:flutter/material.dart';
import '../widgets/dashboard/financial_health_card.dart';
import '../widgets/dashboard/goals_summary_card.dart';
import '../widgets/dashboard/productivity_card.dart';
import '../widgets/dashboard/skills_progress_card.dart';
import '../widgets/dashboard/ai_insight_card.dart';
import '../widgets/dashboard/quick_actions_row.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('LifeLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome greeting
              Text(
                '👋 Welcome back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),

              // AI Insight of the Day
              Text(
                '💡 AI Insight of the Day',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const AIInsightCard(),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const QuickActionsRow(),
              const SizedBox(height: 24),

              // Financial Health Card
              const FinancialHealthCard(),
              const SizedBox(height: 24),

              // Active Goals Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🎯 Active Goals (2)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All →'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const GoalsSummaryCard(),
              const SizedBox(height: 24),

              // Today's Productivity
              Text(
                '⏱️ Today\'s Productivity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const ProductivityCard(),
              const SizedBox(height: 24),

              // Skills Progress
              Text(
                '🧠 Skills Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const SkillsProgressCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
