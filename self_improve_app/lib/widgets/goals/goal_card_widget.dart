import 'package:flutter/material.dart';
import '../../models/goal.dart';

class GoalCardWidget extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMarkAsDone;
  final Function(double)? onAddContribution;

  const GoalCardWidget({
    super.key,
    required this.goal,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
    this.onMarkAsDone,
    this.onAddContribution,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (goal.progress * 100).toInt();
    
    return InkWell(
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
            
            // Title and progress
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
                  if (goal.type == GoalType.saving)
                    Text(
                      '₱${goal.current.toStringAsFixed(0)} / ₱${goal.target.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    )
                  else
                    Text(
                      '${goal.current.toStringAsFixed(0)} / ${goal.target.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
            
            // Progress percentage
            Text(
              '$progress%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            
            // Menu
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                if (goal.status == GoalStatus.active) ...[
                  PopupMenuItem(
                    value: 'edit',
                    child: const Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'mark_done',
                    child: const Text('Mark as Done'),
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
                } else if (value == 'mark_done' && onMarkAsDone != null) {
                  onMarkAsDone!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
