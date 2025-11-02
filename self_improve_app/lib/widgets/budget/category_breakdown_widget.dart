import 'package:flutter/material.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final bool showAll;

  const CategoryBreakdownWidget({
    super.key,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryData(
        emoji: '🍔',
        name: 'Food',
        amount: 450,
        percentage: 0.30,
        color: Colors.orange,
      ),
      CategoryData(
        emoji: '🚗',
        name: 'Transport',
        amount: 200,
        percentage: 0.13,
        color: Colors.blue,
      ),
      CategoryData(
        emoji: '🏠',
        name: 'Housing',
        amount: 300,
        percentage: 0.20,
        color: Colors.purple,
      ),
      CategoryData(
        emoji: '🎮',
        name: 'Entertainment',
        amount: 150,
        percentage: 0.10,
        color: Colors.pink,
      ),
      CategoryData(
        emoji: '🛒',
        name: 'Shopping',
        amount: 100,
        percentage: 0.07,
        color: Colors.green,
      ),
    ];

    final displayCategories = showAll ? categories : categories.take(3).toList();

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
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),

            ...displayCategories.map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _CategoryRow(category: category),
                )),

            if (!showAll)
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('View All Categories →'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryData category;

  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '₱${category.amount}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(category.percentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: category.percentage,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(category.color),
          ),
        ),
      ],
    );
  }
}

class CategoryData {
  final String emoji;
  final String name;
  final int amount;
  final double percentage;
  final Color color;

  CategoryData({
    required this.emoji,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
