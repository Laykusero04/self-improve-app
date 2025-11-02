import 'package:flutter/material.dart';

class OverviewStatsWidget extends StatelessWidget {
  const OverviewStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Key Metrics Cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.account_balance_wallet,
                title: 'Total Balance',
                value: '₱2,450',
                change: '+12%',
                isPositive: true,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.trending_up,
                title: 'Income',
                value: '₱3,000',
                change: '+8%',
                isPositive: true,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.trending_down,
                title: 'Expenses',
                value: '₱1,200',
                change: '-5%',
                isPositive: true,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.timer,
                title: 'Focus Hours',
                value: '156h',
                change: '+20%',
                isPositive: true,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart Section
        Text(
          'Monthly Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.area_chart,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  '[Area Chart - Monthly Trends]',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Goals Progress
        Text(
          'Goals Progress',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _GoalProgressItem(
          title: 'Vacation Fund',
          progress: 0.65,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _GoalProgressItem(
          title: 'New Laptop',
          progress: 0.30,
          color: Colors.purple,
        ),
        const SizedBox(height: 24),

        // Skills Progress
        Text(
          'Skills Development',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _SkillProgressItem(
          title: 'Python',
          hours: 120,
          progress: 0.50,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _SkillProgressItem(
          title: 'Flutter',
          hours: 96,
          progress: 0.40,
          color: Colors.cyan,
        ),
        const SizedBox(height: 12),
        _SkillProgressItem(
          title: 'Design',
          hours: 108,
          progress: 0.45,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressItem extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;

  const _GoalProgressItem({
    required this.title,
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
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
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
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _SkillProgressItem extends StatelessWidget {
  final String title;
  final int hours;
  final double progress;
  final Color color;

  const _SkillProgressItem({
    required this.title,
    required this.hours,
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
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${hours}h • ${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
