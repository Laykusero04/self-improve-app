import 'package:flutter/material.dart';

class WeeklyAnalyticsWidget extends StatelessWidget {
  const WeeklyAnalyticsWidget({super.key});

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
            Text(
              'Time Allocation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),

            // Placeholder for Pie Chart
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '[Interactive Pie Chart]',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Breakdown
            _TimeAllocationRow(
              label: 'Work',
              percentage: 35,
              hours: 28,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _TimeAllocationRow(
              label: 'Leisure',
              percentage: 25,
              hours: 20,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _TimeAllocationRow(
              label: 'Sleep',
              percentage: 30,
              hours: 24,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _TimeAllocationRow(
              label: 'Study',
              percentage: 10,
              hours: 8,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Compare to Last Week'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeAllocationRow extends StatelessWidget {
  final String label;
  final int percentage;
  final int hours;
  final Color color;

  const _TimeAllocationRow({
    required this.label,
    required this.percentage,
    required this.hours,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: $percentage% (${hours}h)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
