import 'package:flutter/material.dart';
import '../widgets/goals/goal_card_widget.dart';
import '../widgets/app_drawer.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            const Text('Goals'),
            const SizedBox(width: 8),
            Text(
              '🎯',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add goal
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Filter Tabs
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
              isScrollable: true,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Archived'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Tab
                _buildGoalsList(showAll: true),

                // Active Tab
                _buildGoalsList(showActive: true),

                // Completed Tab
                _buildGoalsList(showCompleted: true),

                // Archived Tab
                _buildGoalsList(showArchived: true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add goal
        },
        icon: const Icon(Icons.flag),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildGoalsList({
    bool showAll = false,
    bool showActive = false,
    bool showCompleted = false,
    bool showArchived = false,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active Goals
        if (showAll || showActive) ...[
          Text(
            '🎯 Active Goals (2)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          GoalCardWidget(
            emoji: '🏖️',
            title: 'Vacation Fund',
            progress: 0.65,
            current: 3250,
            target: 5000,
            targetDate: DateTime(2024, 12, 31),
            suggestedWeekly: 39,
          ),
          const SizedBox(height: 16),
          GoalCardWidget(
            emoji: '💻',
            title: 'New Laptop',
            progress: 0.30,
            current: 900,
            target: 3000,
            targetDate: DateTime(2025, 3, 15),
            suggestedWeekly: 18,
          ),
          const SizedBox(height: 24),
        ],

        // Completed Goals
        if (showAll || showCompleted) ...[
          Text(
            'Completed Goals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _buildCompletedGoalCard(
            emoji: '✅',
            title: 'Emergency Fund',
            amount: 5000,
            completedDate: DateTime(2024, 10, 15),
          ),
          const SizedBox(height: 24),
        ],

        // Empty State for Archived
        if (showArchived) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Archived Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Archived goals will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedGoalCard({
    required String emoji,
    required String title,
    required int amount,
    required DateTime completedDate,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Completed: ${_formatDate(completedDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ₱${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.archive_outlined, size: 20),
                    label: const Text('Archive'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
