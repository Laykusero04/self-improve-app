import 'package:flutter/material.dart';
import '../widgets/activity/timer_widget.dart';
import '../widgets/activity/today_summary_widget.dart';
import '../widgets/activity/sessions_list_widget.dart';
import '../widgets/activity/skills_progress_detail_widget.dart';
import '../widgets/app_drawer.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Row(
          children: [
            const Text('Activity'),
            const SizedBox(width: 8),
            Text(
              '⏱️',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add session manually
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // TODO: Navigate to statistics
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Widget (Collapsible)
            const TimerWidget(),

            // Today's Summary
            const Padding(
              padding: EdgeInsets.all(16),
              child: TodaySummaryWidget(),
            ),

            // Time Period Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.calendar_today), text: 'Today'),
                  Tab(icon: Icon(Icons.date_range), text: 'This Week'),
                  Tab(icon: Icon(Icons.calendar_month), text: 'Month'),
                ],
              ),
            ),

            // Tab Bar View Content
            SizedBox(
              height: 600, // Fixed height for the tab content
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Today Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Sessions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const SessionsListWidget(period: 'today'),
                        const SizedBox(height: 24),
                        Text(
                          '🧠 Skills Progress',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const SkillsProgressDetailWidget(),
                      ],
                    ),
                  ),

                  // This Week Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Week\'s Sessions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const SessionsListWidget(period: 'week'),
                        const SizedBox(height: 24),
                        Text(
                          '🧠 Skills Progress',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const SkillsProgressDetailWidget(),
                      ],
                    ),
                  ),

                  // Month Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Month\'s Sessions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const SessionsListWidget(period: 'month'),
                        const SizedBox(height: 24),
                        Text(
                          '🧠 Skills Progress',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const SkillsProgressDetailWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Start new timer
        },
        icon: const Icon(Icons.play_circle_outline),
        label: const Text('Start Timer'),
      ),
    );
  }
}
