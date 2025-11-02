import 'package:flutter/material.dart';

class TrendsWidget extends StatelessWidget {
  const TrendsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '[Line Chart - Weekly Trends]',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Trends Summary
            _TrendItem(
              label: 'Spending Trend',
              value: 'Down 12%',
              icon: Icons.trending_down,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _TrendItem(
              label: 'Productivity',
              value: 'Up 20%',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _TrendItem(
              label: 'Skill Growth',
              value: 'Up 15%',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics_outlined, size: 20),
                label: const Text('View Detailed Analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrendItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
