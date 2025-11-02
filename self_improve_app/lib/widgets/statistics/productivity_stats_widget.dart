import 'package:flutter/material.dart';

class ProductivityStatsWidget extends StatelessWidget {
  const ProductivityStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Total Hours',
                      value: '156h',
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                    _StatItem(
                      label: 'Sessions',
                      value: '42',
                      icon: Icons.event,
                      color: Colors.green,
                    ),
                    _StatItem(
                      label: 'Avg/Day',
                      value: '5.2h',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Weekly Trend Chart
        Text(
          'Weekly Focus Hours',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
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
                  Icons.bar_chart,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  '[Bar Chart - Weekly Hours]',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Activity Breakdown
        Text(
          'Time by Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _ActivityItem(
          emoji: '💻',
          name: 'Coding',
          hours: 72,
          percentage: 46,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _ActivityItem(
          emoji: '🎨',
          name: 'Design',
          hours: 48,
          percentage: 31,
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _ActivityItem(
          emoji: '📚',
          name: 'Learning',
          hours: 36,
          percentage: 23,
          color: Colors.orange,
        ),
        const SizedBox(height: 24),

        // Best Performing Days
        Text(
          'Best Performing Days',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _DayPerformanceItem(day: 'Monday', hours: 8.5, color: Colors.green),
        const SizedBox(height: 8),
        _DayPerformanceItem(day: 'Wednesday', hours: 7.8, color: Colors.blue),
        const SizedBox(height: 8),
        _DayPerformanceItem(day: 'Friday', hours: 7.2, color: Colors.orange),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String emoji;
  final String name;
  final int hours;
  final int percentage;
  final Color color;

  const _ActivityItem({
    required this.emoji,
    required this.name,
    required this.hours,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '${hours}h',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _DayPerformanceItem extends StatelessWidget {
  final String day;
  final double hours;
  final Color color;

  const _DayPerformanceItem({
    required this.day,
    required this.hours,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Row(
            children: [
              Text(
                '${hours}h',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.star, color: color, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
