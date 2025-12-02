import 'package:flutter/material.dart';
import '../widgets/activity/timer_widget.dart';
import '../widgets/activity/today_summary_card.dart';
import '../widgets/activity/weekly_chart_widget.dart';
import '../widgets/app_drawer.dart';
import 'app_selection_screen.dart';
import 'focus_stats_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _refreshKey = 0;

  void _refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

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
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'View Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FocusStatsScreen(),
                ),
              ).then((_) {
                // Refresh data when returning from stats screen
                _refreshData();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: 'Select apps to block',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TimerWidget(
              onSessionSaved: _refreshData,
            ),
            TodaySummaryCard(key: ValueKey('today_summary_$_refreshKey')),
            WeeklyChartWidget(key: ValueKey('weekly_chart_$_refreshKey')),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FocusStatsScreen(),
                    ),
                  ).then((_) {
                    _refreshData();
                  });
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text('View Full Statistics'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
