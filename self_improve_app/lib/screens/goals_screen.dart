import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/goals/goals_bloc.dart';
import '../bloc/goals/goals_event.dart';
import '../bloc/goals/goals_state.dart';
import '../widgets/goals/goal_card_widget.dart';
import '../widgets/goals/add_goal_dialog.dart';
import '../widgets/app_drawer.dart';
import '../models/goal.dart';

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
    return BlocProvider(
      create: (context) => GoalsBloc()..add(const GoalsInitialized()),
      child: Builder(
        builder: (context) => _GoalsView(),
      ),
    );
  }
}

class _GoalsView extends StatefulWidget {
  const _GoalsView();

  @override
  State<_GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<_GoalsView> with SingleTickerProviderStateMixin {
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

  void _showAddGoalDialog() {
    final bloc = context.read<GoalsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const AddGoalDialog(),
      ),
    );
  }

  void _showDeleteConfirmDialog(Goal goal) {
    final bloc = context.read<GoalsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AlertDialog(
          title: const Text('Delete Goal'),
          content: Text('Are you sure you want to delete "${goal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                bloc.add(GoalDeleted(goal.id!));
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalDialog(Goal goal) {
    final bloc = context.read<GoalsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AddGoalDialog(goal: goal),
      ),
    );
  }

  void _showViewDetails(Goal goal) {
    // TODO: Implement view details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for "${goal.title}"')),
    );
  }

  void _handleAddContribution(Goal goal, double amount) {
    if (goal.id != null) {
      context.read<GoalsBloc>().add(ContributionAdded(goal.id!, amount));
    }
  }

  void _showArchiveConfirmDialog(Goal goal) {
    final bloc = context.read<GoalsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AlertDialog(
          title: const Text('Archive Goal'),
          content: Text('Are you sure you want to archive "${goal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                bloc.add(GoalStatusChanged(goal.id!, GoalStatus.archived));
              },
              child: const Text('Archive'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkAsDoneConfirmDialog(Goal goal) {
    final bloc = context.read<GoalsBloc>();
    final progress = (goal.progress * 100).toInt();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AlertDialog(
          title: const Text('Mark as Done'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mark "${goal.title}" as completed?'),
              const SizedBox(height: 12),
              Text(
                'Current progress: $progress% (₱${goal.current.toStringAsFixed(0)} / ₱${goal.target.toStringAsFixed(0)})',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (progress < 100)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'This goal has not reached the target yet.',
                    style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                          color: Theme.of(dialogContext).colorScheme.error,
                        ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                bloc.add(GoalStatusChanged(goal.id!, GoalStatus.completed));
              },
              child: const Text('Mark as Done'),
            ),
          ],
        ),
      ),
    );
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
            onPressed: _showAddGoalDialog,
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
            child: BlocListener<GoalsBloc, GoalsState>(
              listenWhen: (previous, current) =>
                  current.recentlyCompletedGoalTitle != null &&
                  previous.recentlyCompletedGoalTitle != current.recentlyCompletedGoalTitle,
              listener: (context, state) {
                if (state.recentlyCompletedGoalTitle != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '🎉 "${state.recentlyCompletedGoalTitle}" goal completed!',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  // Clear the recently completed title after showing
                  context.read<GoalsBloc>().add(const GoalsRefreshed());
                }
              },
              child: BlocBuilder<GoalsBloc, GoalsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${state.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GoalsBloc>().add(const GoalsRefreshed());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // All Tab
                      _buildGoalsList(
                        goals: state.allGoals,
                        showAll: true,
                        emptyMessage: 'No goals yet. Create your first goal to get started!',
                      ),

                      // Active Tab
                      _buildGoalsList(
                        goals: state.activeGoals,
                        showActive: true,
                        emptyMessage: 'No active goals. Create a new goal to get started!',
                      ),

                      // Completed Tab
                      _buildCompletedGoalsList(
                        goals: state.completedGoals,
                        emptyMessage: 'No completed goals yet.',
                      ),

                      // Archived Tab
                      _buildGoalsList(
                        goals: state.archivedGoals,
                        showArchived: true,
                        emptyMessage: 'No archived goals.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.flag),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildGoalsList({
    required List<Goal> goals,
    bool showAll = false,
    bool showActive = false,
    bool showArchived = false,
    required String emptyMessage,
  }) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                showArchived ? Icons.archive_outlined : Icons.flag_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (showAll || showActive) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (showAll)
            Text(
              '🎯 Active Goals (${goals.where((g) => g.status == GoalStatus.active).length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            )
          else
            Text(
              '🎯 Active Goals (${goals.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const SizedBox(height: 16),
          ...goals
              .where((g) => showAll ? g.status == GoalStatus.active : true)
              .map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GoalCardWidget(
                      goal: goal,
                      onEdit: () => _showEditGoalDialog(goal),
                      onDelete: () => _showDeleteConfirmDialog(goal),
                      onMarkAsDone: () => _showMarkAsDoneConfirmDialog(goal),
                      onViewDetails: () => _showViewDetails(goal),
                      onAddContribution: (amount) => _handleAddContribution(goal, amount),
                    ),
                  )),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: goals
          .map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GoalCardWidget(
                  goal: goal,
                  onEdit: () => _showEditGoalDialog(goal),
                  onDelete: () => _showDeleteConfirmDialog(goal),
                  onViewDetails: () => _showViewDetails(goal),
                  onAddContribution: (amount) => _handleAddContribution(goal, amount),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCompletedGoalsList({
    required List<Goal> goals,
    required String emptyMessage,
  }) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Completed Goals (${goals.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        ...goals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCompletedGoalCard(goal),
            )),
      ],
    );
  }

  Widget _buildCompletedGoalCard(Goal goal) {
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
                  goal.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Completed: ${_formatDate(goal.completedDate ?? goal.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ₱${goal.current.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewDetails(goal),
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showArchiveConfirmDialog(goal),
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
