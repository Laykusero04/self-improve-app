import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/goals/goals_bloc.dart';
import '../bloc/goals/goals_event.dart';
import '../bloc/goals/goals_state.dart';
import '../widgets/goals/goal_card_widget.dart';
import 'add_goal_screen.dart';
import '../widgets/app_drawer.dart';
import '../models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {

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

enum FilterType {
  all,
  habits,
  savings,
  active,
  completed,
  archived,
}

class _GoalsViewState extends State<_GoalsView> {
  FilterType _selectedFilter = FilterType.all;

  void _showAddGoalScreen() {
    final bloc = context.read<GoalsBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const AddGoalScreen(),
        ),
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

  void _showEditGoalScreen(Goal goal) {
    final bloc = context.read<GoalsBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: AddGoalScreen(goal: goal),
        ),
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
            onPressed: _showAddGoalScreen,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(
                    icon: Icons.inbox,
                    label: 'All',
                    filter: FilterType.all,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.repeat,
                    label: 'Habits',
                    filter: FilterType.habits,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.savings,
                    label: 'Savings',
                    filter: FilterType.savings,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.play_circle_outline,
                    label: 'Active',
                    filter: FilterType.active,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.check_circle_outline,
                    label: 'Completed',
                    filter: FilterType.completed,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.archive_outlined,
                    label: 'Archive',
                    filter: FilterType.archived,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: BlocListener<GoalsBloc, GoalsState>(
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

            // Filter goals based on selected filter
            List<Goal> filteredGoals;
            bool showAll = false;
            bool showActive = false;
            bool showArchived = false;
            String emptyMessage;

            switch (_selectedFilter) {
              case FilterType.all:
                filteredGoals = state.allGoals;
                showAll = true;
                emptyMessage = 'No goals yet. Create your first goal to get started!';
                break;
              case FilterType.habits:
                filteredGoals = state.allGoals.where((g) => g.type == GoalType.habit).toList();
                showActive = true;
                emptyMessage = 'No habits yet. Create your first habit!';
                break;
              case FilterType.savings:
                filteredGoals = state.allGoals.where((g) => g.type == GoalType.saving).toList();
                showActive = true;
                emptyMessage = 'No savings goals yet. Create your first savings goal!';
                break;
              case FilterType.active:
                filteredGoals = state.activeGoals;
                showActive = true;
                emptyMessage = 'No active goals. Create a new goal to get started!';
                break;
              case FilterType.completed:
                return _buildCompletedGoalsList(
                  goals: state.completedGoals,
                  emptyMessage: 'No completed goals yet.',
                );
              case FilterType.archived:
                filteredGoals = state.archivedGoals;
                showArchived = true;
                emptyMessage = 'No archived goals.';
                break;
            }

            return _buildGoalsList(
              goals: filteredGoals,
              showAll: showAll,
              showActive: showActive,
              showArchived: showArchived,
              emptyMessage: emptyMessage,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalScreen,
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

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: goals.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      itemBuilder: (context, index) {
        final goal = goals[index];
        return GoalCardWidget(
          goal: goal,
          onEdit: () => _showEditGoalScreen(goal),
          onDelete: () => _showDeleteConfirmDialog(goal),
          onMarkAsDone: showActive || showAll ? () => _showMarkAsDoneConfirmDialog(goal) : null,
          onViewDetails: () => _showViewDetails(goal),
          onAddContribution: (amount) => _handleAddContribution(goal, amount),
        );
      },
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

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: goals.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildCompletedGoalCard(goal);
      },
    );
  }

  Widget _buildCompletedGoalCard(Goal goal) {
    return InkWell(
      onTap: () => _showViewDetails(goal),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: goal.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                goal.type == GoalType.habit ? Icons.repeat : Icons.savings,
                color: goal.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Title and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.type == GoalType.saving 
                        ? '₱${goal.current.toStringAsFixed(0)}'
                        : '${goal.current.toStringAsFixed(0)} times',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            
            // Menu
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: const Text('View Details'),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: const Text('Archive'),
                ),
              ],
              onSelected: (value) {
                if (value == 'view') {
                  _showViewDetails(goal);
                } else if (value == 'archive') {
                  _showArchiveConfirmDialog(goal);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required FilterType filter,
  }) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

