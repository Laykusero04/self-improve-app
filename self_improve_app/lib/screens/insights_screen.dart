import 'package:flutter/material.dart';
import '../widgets/insights/daily_ai_summary_widget.dart';
import '../widgets/insights/weekly_analytics_widget.dart';
import '../widgets/insights/spending_insights_widget.dart';
import '../widgets/insights/goal_recommendations_widget.dart';
import '../widgets/insights/trends_widget.dart';
import '../widgets/insights/predictions_widget.dart';
import '../widgets/app_drawer.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
        title: Row(
          children: [
            const Text('Insights'),
            const SizedBox(width: 8),
            Text(
              '🧠',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to insights settings
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh insights
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily AI Summary
              Text(
                '💡 Daily AI Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const DailyAISummaryWidget(),
              const SizedBox(height: 24),

              // Weekly Analytics
              Text(
                '📊 Weekly Analytics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const WeeklyAnalyticsWidget(),
              const SizedBox(height: 24),

              // Spending Insights
              Text(
                '💰 Spending Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const SpendingInsightsWidget(),
              const SizedBox(height: 24),

              // Goal Recommendations
              Text(
                '🎯 Goal Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const GoalRecommendationsWidget(),
              const SizedBox(height: 24),

              // Trends & Patterns
              Text(
                '📈 Trends & Patterns',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const TrendsWidget(),
              const SizedBox(height: 24),

              // Predictions
              Text(
                '🔮 Predictions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              const PredictionsWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
