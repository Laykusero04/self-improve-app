import 'package:flutter/material.dart';

class FinancialStatsWidget extends StatelessWidget {
  const FinancialStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Total Income',
                  value: '₱3,000',
                  color: Colors.green,
                ),
                const Divider(),
                _SummaryRow(
                  label: 'Total Expenses',
                  value: '₱1,200',
                  color: Colors.red,
                ),
                const Divider(),
                _SummaryRow(
                  label: 'Net Savings',
                  value: '₱1,800',
                  color: Colors.blue,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Income vs Expenses Chart
        Text(
          'Income vs Expenses',
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
                  '[Bar Chart - Monthly Comparison]',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Category Breakdown
        Text(
          'Spending by Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _CategoryItem(
          emoji: '🍔',
          name: 'Food',
          amount: 450,
          percentage: 37,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _CategoryItem(
          emoji: '🚗',
          name: 'Transport',
          amount: 200,
          percentage: 17,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _CategoryItem(
          emoji: '🏠',
          name: 'Housing',
          amount: 300,
          percentage: 25,
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _CategoryItem(
          emoji: '🎮',
          name: 'Entertainment',
          amount: 150,
          percentage: 13,
          color: Colors.pink,
        ),
        const SizedBox(height: 12),
        _CategoryItem(
          emoji: '🛒',
          name: 'Shopping',
          amount: 100,
          percentage: 8,
          color: Colors.green,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String emoji;
  final String name;
  final int amount;
  final int percentage;
  final Color color;

  const _CategoryItem({
    required this.emoji,
    required this.name,
    required this.amount,
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
              '₱$amount',
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
