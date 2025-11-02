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
    final remaining = goal.remaining;
    final daysRemaining = goal.daysRemaining;
    final suggestedWeekly = goal.suggestedWeekly;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        enabled: goal.status == GoalStatus.active,
                        child: const Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'mark_done',
                        enabled: goal.status == GoalStatus.active,
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 12),
                            Text('Mark as Done'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Delete'),
                          ],
                        ),
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
              const SizedBox(height: 20),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 12,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Percentage
              Text(
                '${(goal.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₱${goal.current.toStringAsFixed(0)} / ₱${goal.target.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${remaining.toStringAsFixed(0)} remaining',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Target Date
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _formatDate(goal.targetDate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '$daysRemaining days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suggested:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Row(
                          children: [
                            Text(
                              '₱$suggestedWeekly/week',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions
              if (goal.status == GoalStatus.active) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showFlexibleSaveDialog(context),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Quick Save'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.bar_chart, size: 20),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFlexibleSaveDialog(BuildContext context) {
    final suggestedWeekly = goal.suggestedWeekly;
    final suggestedDaily = (suggestedWeekly / 7).ceil();
    final suggestedMonthly = suggestedWeekly * 4;

    showDialog(
      context: context,
      builder: (context) => _FlexibleSaveDialogContent(
        goalTitle: goal.title,
        suggestedDaily: suggestedDaily,
        suggestedWeekly: suggestedWeekly,
        suggestedMonthly: suggestedMonthly,
        onAddContribution: onAddContribution,
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

class _FlexibleSaveDialogContent extends StatefulWidget {
  final String goalTitle;
  final int suggestedDaily;
  final int suggestedWeekly;
  final int suggestedMonthly;
  final Function(double)? onAddContribution;

  const _FlexibleSaveDialogContent({
    required this.goalTitle,
    required this.suggestedDaily,
    required this.suggestedWeekly,
    required this.suggestedMonthly,
    this.onAddContribution,
  });

  @override
  State<_FlexibleSaveDialogContent> createState() => _FlexibleSaveDialogContentState();
}

class _FlexibleSaveDialogContentState extends State<_FlexibleSaveDialogContent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add to ${widget.goalTitle}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick options based on suggested amount
            Text(
              'Quick Options',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAmountChip(
                  context,
                  widget.suggestedDaily,
                  'Day',
                  _controller,
                ),
                _buildAmountChip(
                  context,
                  widget.suggestedWeekly,
                  'Week',
                  _controller,
                ),
                _buildAmountChip(
                  context,
                  widget.suggestedMonthly,
                  'Month',
                  _controller,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Custom amount
            Text(
              'Or Enter Custom Amount',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            final amount = double.tryParse(text);
            if (amount != null && amount > 0) {
              Navigator.pop(context);
              if (widget.onAddContribution != null) {
                widget.onAddContribution!(amount);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('₱${amount.toStringAsFixed(0)} added successfully!')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildAmountChip(
    BuildContext context,
    int amount,
    String period,
    TextEditingController controller,
  ) {
    final isSelected = controller.text == amount.toString();
    return InkWell(
      onTap: () {
        setState(() {
          controller.text = amount.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₱$amount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '/$period',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
