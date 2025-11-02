import 'package:flutter/material.dart';

class GoalsSummaryCard extends StatelessWidget {
  const GoalsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GoalCard(
            emoji: '🏖️',
            title: 'Vacation',
            progress: 0.65,
            current: 3250,
            target: 5000,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GoalCard(
            emoji: '💻',
            title: 'Laptop',
            progress: 0.30,
            current: 900,
            target: 3000,
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String emoji;
  final String title;
  final double progress;
  final int current;
  final int target;

  const _GoalCard({
    required this.emoji,
    required this.title,
    required this.progress,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Percentage
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),

            // Amount
            Text(
              '₱${current.toStringAsFixed(0)}/₱${(target / 1000).toStringAsFixed(0)}K',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
