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
  activities,
  financial,
  active,
  completed,
  archived,
}

class _GoalsViewState extends State<_GoalsView> {
  FilterType _selectedFilter = FilterType.all;
  bool _isSuccessSectionExpanded = true;

  bool _isCompletedToday(Goal goal) {
    if (goal.status != GoalStatus.completed || goal.completedDate == null) {
      return false;
    }
    final now = DateTime.now();
    final completed = goal.completedDate!;
    return now.year == completed.year &&
        now.month == completed.month &&
        now.day == completed.day;
  }

  List<Goal> _getTodayCompletedGoals(List<Goal> allCompletedGoals) {
    return allCompletedGoals.where((g) => _isCompletedToday(g)).toList();
  }

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

  void _handleLogProgress(Goal goal) {
    final bloc = context.read<GoalsBloc>();

    // Show dialog to optionally add a note
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log progress for "${goal.title}"?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a note about your progress...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store note temporarily
              },
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
              if (goal.id != null) {
                // Increment progress by 1
                bloc.add(ContributionAdded(goal.id!, 1));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress logged for "${goal.title}"'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Log Progress'),
          ),
        ],
      ),
    );
  }

  void _handleAddNote(Goal goal) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            hintText: 'Add a note about this goal...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (noteController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Note added for "${goal.title}"'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  void _handleSkip(Goal goal) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Skip Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skip "${goal.title}" for today?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Why are you skipping this goal?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Skipped "${goal.title}" for today'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _handleFail(Goal goal) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark "${goal.title}" as failed?'),
            const SizedBox(height: 8),
            Text(
              'This will help you understand what went wrong.',
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'What prevented you from completing this?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed attempt logged for "${goal.title}"'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Mark Failed'),
          ),
        ],
      ),
    );
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
    
    // For financial goals, ask for amount first before completing
    if (goal.type == GoalType.financial) {
      final amountController = TextEditingController();
      
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add Amount for Today'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the amount you saved for "${goal.title}" today:'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (₱)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '₱',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Current: ₱${goal.current.toStringAsFixed(0)} / Target: ₱${goal.target.toStringAsFixed(0)}',
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                      color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
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
                final amountText = amountController.text.trim();
                if (amountText.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid positive amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(dialogContext);
                
                // Add contribution and mark as completed in one operation
                bloc.add(ContributionAdded(goal.id!, amount, markAsCompleted: true));
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      );
    } else {
      // For activity goals, add 1 to current progress
      // Mark as completed only when current >= timesPerDay (target)
      bloc.add(ContributionAdded(goal.id!, 1.0, markAsCompleted: false));
    }
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
                    label: 'Activities',
                    filter: FilterType.activities,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.savings,
                    label: 'Financial',
                    filter: FilterType.financial,
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
          if (state.recentlyCompletedGoalTitle != null && state.recentlyCompletedGoalId != null) {
            final goalId = state.recentlyCompletedGoalId!;
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
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () {
                    final bloc = context.read<GoalsBloc>();
                    bloc.add(GoalStatusChanged(goalId, GoalStatus.active));
                  },
                ),
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
            switch (_selectedFilter) {
              case FilterType.all:
                return _buildGoalsListWithSuccessSection(
                  activeGoals: state.activeGoals,
                  completedGoals: state.completedGoals,
                  emptyMessage: 'No goals yet. Create your first goal to get started!',
                );
              case FilterType.activities:
                final activityGoals = state.allGoals.where((g) => g.type == GoalType.activity).toList();
                final activeActivities = activityGoals.where((g) => g.status == GoalStatus.active).toList();
                final completedActivities = activityGoals.where((g) => g.status == GoalStatus.completed).toList();
                return _buildGoalsListWithSuccessSection(
                  activeGoals: activeActivities,
                  completedGoals: completedActivities,
                  emptyMessage: 'No activities yet. Create your first activity!',
                );
              case FilterType.financial:
                final financialGoals = state.allGoals.where((g) => g.type == GoalType.financial).toList();
                final activeFinancial = financialGoals.where((g) => g.status == GoalStatus.active).toList();
                final completedFinancial = financialGoals.where((g) => g.status == GoalStatus.completed).toList();
                return _buildGoalsListWithSuccessSection(
                  activeGoals: activeFinancial,
                  completedGoals: completedFinancial,
                  emptyMessage: 'No financial goals yet. Create your first financial goal!',
                );
              case FilterType.active:
                return _buildGoalsListWithSuccessSection(
                  activeGoals: state.activeGoals,
                  completedGoals: state.completedGoals,
                  emptyMessage: 'No active goals. Create a new goal to get started!',
                );
              case FilterType.completed:
                return _buildCompletedGoalsList(
                  goals: state.completedGoals,
                  emptyMessage: 'No completed goals yet.',
                );
              case FilterType.archived:
                return _buildGoalsList(
                  goals: state.archivedGoals,
                  showAll: false,
                  showActive: false,
                  showArchived: true,
                  emptyMessage: 'No archived goals.',
                );
            }
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

  Widget _buildGoalsListWithSuccessSection({
    required List<Goal> activeGoals,
    required List<Goal> completedGoals,
    required String emptyMessage,
  }) {
    final todayCompleted = _getTodayCompletedGoals(completedGoals);

    if (activeGoals.isEmpty && todayCompleted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
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
      padding: EdgeInsets.zero,
      children: [
        // Active goals
        if (activeGoals.isNotEmpty)
          ...activeGoals.map((goal) => Column(
                children: [
                  GoalCardWidget(
                    goal: goal,
                    onEdit: () => _showEditGoalScreen(goal),
                    onDelete: () => _showDeleteConfirmDialog(goal),
                    onMarkAsDone: () => _showMarkAsDoneConfirmDialog(goal),
                    onViewDetails: () => _showViewDetails(goal),
                    onAddContribution: (amount) => _handleAddContribution(goal, amount),
                    onLogProgress: () => _handleLogProgress(goal),
                    onAddNote: () => _handleAddNote(goal),
                    onSkip: () => _handleSkip(goal),
                    onFail: () => _handleFail(goal),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ],
              )),

        // Success section
        if (todayCompleted.isNotEmpty)
          Theme(
            data: Theme.of(context),
            child: ExpansionTile(
              title: Text(
                '${todayCompleted.length} Success',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              initiallyExpanded: _isSuccessSectionExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isSuccessSectionExpanded = expanded;
                });
              },
              children: todayCompleted.map((goal) => Column(
                    children: [
                      GoalCardWidget(
                        goal: goal,
                        onEdit: () => _showEditGoalScreen(goal),
                        onDelete: () => _showDeleteConfirmDialog(goal),
                        onMarkAsDone: null,
                        onViewDetails: () => _showViewDetails(goal),
                        onAddContribution: (amount) => _handleAddContribution(goal, amount),
                        onLogProgress: () => _handleLogProgress(goal),
                        onAddNote: () => _handleAddNote(goal),
                        onSkip: () => _handleSkip(goal),
                        onFail: () => _handleFail(goal),
                        onUndo: () {
                          final bloc = context.read<GoalsBloc>();
                          bloc.add(GoalStatusChanged(goal.id!, GoalStatus.active));
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  )).toList(),
            ),
          ),
      ],
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
          onLogProgress: () => _handleLogProgress(goal),
          onAddNote: () => _handleAddNote(goal),
          onSkip: () => _handleSkip(goal),
          onFail: () => _handleFail(goal),
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
                goal.type == GoalType.activity ? Icons.repeat : Icons.savings,
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
                    goal.type == GoalType.financial 
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

