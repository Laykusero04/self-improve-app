import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../models/goal.dart';

class GoalCardWidget extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMarkAsDone;
  final Function(double)? onAddContribution;
  final VoidCallback? onLogProgress;
  final VoidCallback? onAddNote;
  final VoidCallback? onSkip;
  final VoidCallback? onFail;
  final VoidCallback? onUndo;

  const GoalCardWidget({
    super.key,
    required this.goal,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
    this.onMarkAsDone,
    this.onAddContribution,
    this.onLogProgress,
    this.onAddNote,
    this.onSkip,
    this.onFail,
    this.onUndo,
  });

  String _formatEndCondition() {
    switch (goal.endConditionType) {
      case EndConditionType.never:
        return 'Never';
      case EndConditionType.onDate:
        if (goal.targetDate != null) {
          return 'On date: ${DateFormat('MMM d, yyyy').format(goal.targetDate!)}';
        }
        return 'On date: Not set';
      case EndConditionType.afterStreaks:
        return 'After streaks: ${goal.endConditionValue ?? 0}';
      case EndConditionType.afterCompletions:
        return 'After completions: ${goal.endConditionValue ?? 0}';
      case EndConditionType.byTotalAmount:
        return 'By total amount: ${goal.endConditionValue ?? 0}';
    }
  }

  bool _isCompletedToday() {
    if (goal.status != GoalStatus.completed || goal.completedDate == null) {
      return false;
    }
    final now = DateTime.now();
    final completed = goal.completedDate!;
    return now.year == completed.year &&
        now.month == completed.month &&
        now.day == completed.day;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (goal.progress * 100).toInt();
    final isCompleted = goal.status == GoalStatus.completed;
    final isCompletedToday = _isCompletedToday();
    final showAsCompleted = isCompleted && isCompletedToday;

    return Slidable(
      key: ValueKey(goal.id),

      // Left to right swipe - Complete/Undo and log progress
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          if (showAsCompleted && onUndo != null)
            // Show Undo for completed goals
            SlidableAction(
              onPressed: (context) {
                onUndo!();
              },
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              icon: Icons.undo,
              label: 'Undo',
            )
          else if (!showAsCompleted) ...[
            // Show Complete and Progress for active goals
            if (onMarkAsDone != null)
              SlidableAction(
                onPressed: (context) {
                  onMarkAsDone!();
                },
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                icon: Icons.check_circle,
                label: 'Complete',
              ),
            if (onLogProgress != null)
              SlidableAction(
                onPressed: (context) {
                  onLogProgress!();
                },
                backgroundColor: const Color(0xFF66BB6A),
                foregroundColor: Colors.white,
                icon: Icons.trending_up,
                label: 'Progress',
              ),
          ],
        ],
      ),

      // Right to left swipe - Note, Skip, Fail
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          // Show Note, Skip, Fail for both completed and active goals
          SlidableAction(
            onPressed: (context) {
              if (onAddNote != null) {
                onAddNote!();
              }
            },
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            icon: Icons.note_add,
            label: 'Note',
          ),
          SlidableAction(
            onPressed: (context) {
              if (onSkip != null) {
                onSkip!();
              }
            },
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            icon: Icons.skip_next,
            label: 'Skip',
          ),
          SlidableAction(
            onPressed: (context) {
              if (onFail != null) {
                onFail!();
              }
            },
            backgroundColor: const Color(0xFFF44336),
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Fail',
          ),
        ],
      ),

      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: showAsCompleted 
                      ? Colors.grey.withOpacity(0.1)
                      : goal.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  goal.type == GoalType.activity ? Icons.repeat : Icons.savings,
                  color: showAsCompleted ? Colors.grey : goal.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title and progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: showAsCompleted ? TextDecoration.lineThrough : null,
                            color: showAsCompleted 
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (goal.type == GoalType.financial)
                      Text(
                        '₱${goal.current.toStringAsFixed(0)} / ₱${goal.target.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      )
                    else
                      Text(
                        showAsCompleted 
                            ? '${goal.timesPerDay} / ${goal.timesPerDay} times'
                            : '${goal.current.toStringAsFixed(0)} / ${goal.target.toStringAsFixed(0)} times',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    if (!showAsCompleted) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Start: ${DateFormat('MMM d, yyyy').format(goal.startDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'End: ${_formatEndCondition()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              // Done button for active goals or checkmark for completed
              if (!showAsCompleted) ...[
                if (goal.status == GoalStatus.active && onMarkAsDone != null)
                  OutlinedButton.icon(
                    onPressed: onMarkAsDone,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Done'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                if (goal.status == GoalStatus.active && onMarkAsDone != null) ...[
                  const SizedBox(width: 8),
                ] else ...[
                  // Progress percentage for non-completed goals
                  Text(
                    '$progress%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Menu
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    if (goal.status == GoalStatus.active) ...[
                      PopupMenuItem(
                        value: 'edit',
                        child: const Text('Edit'),
                      ),
                    ],
                    PopupMenuItem(
                      value: 'delete',
                      child: const Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                ),
              ] else if (showAsCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Colors.grey,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
