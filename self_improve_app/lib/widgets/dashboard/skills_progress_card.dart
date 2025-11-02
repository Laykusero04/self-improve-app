import 'package:flutter/material.dart';

class SkillsProgressCard extends StatelessWidget {
  const SkillsProgressCard({super.key});

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
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _SkillProgressRow(
              skillName: 'Design',
              progress: 0.40,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _SkillProgressRow(
              skillName: 'Flutter',
              progress: 0.20,
              color: Colors.cyan,
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
  final Color color;

  const _SkillProgressRow({
    required this.skillName,
    required this.progress,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
