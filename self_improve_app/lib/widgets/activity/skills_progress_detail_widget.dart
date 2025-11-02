import 'package:flutter/material.dart';

class SkillsProgressDetailWidget extends StatelessWidget {
  const SkillsProgressDetailWidget({super.key});

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
          children: [
            _SkillProgressRow(
              skillName: 'Python',
              progress: 0.50,
              hours: 120,
              weeklyProgress: 8,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _SkillProgressRow(
              skillName: 'Flutter',
              progress: 0.40,
              hours: 96,
              weeklyProgress: 5,
              color: Colors.cyan,
            ),
            const SizedBox(height: 20),
            _SkillProgressRow(
              skillName: 'Design',
              progress: 0.45,
              hours: 108,
              weeklyProgress: 6,
              color: Colors.purple,
            ),
            const SizedBox(height: 20),

            // Add New Skill Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Add new skill
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add New Skill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillProgressRow extends StatelessWidget {
  final String skillName;
  final double progress;
  final int hours;
  final int weeklyProgress;
  final Color color;

  const _SkillProgressRow({
    required this.skillName,
    required this.progress,
    required this.hours,
    required this.weeklyProgress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skillName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),

        // Hours and Weekly Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${hours}h total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Row(
              children: [
                Text(
                  'This week: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '+${weeklyProgress}h',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
