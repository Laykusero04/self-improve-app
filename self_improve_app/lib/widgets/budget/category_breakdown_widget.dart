import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_state.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final bool showAll;

  const CategoryBreakdownWidget({
    super.key,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state.isLoading && state.categoryTotals.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state.categoryTotals.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No category data available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          );
        }

        final totalExpenses = state.totalExpenses;
        final categoryData = _buildCategoryData(state, totalExpenses);

        final displayCategories = showAll
            ? categoryData
            : categoryData.take(3).toList();

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

                if (!showAll && categoryData.length > 3)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Switch to Categories tab (index 2)
                        DefaultTabController.of(context).animateTo(2);
                      },
                      child: const Text('View All Categories →'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<CategoryData> _buildCategoryData(BudgetState state, double totalExpenses) {
    final List<CategoryData> result = [];

    for (final entry in state.categoryTotals.entries) {
      final categoryName = entry.key;
      final amount = entry.value.abs(); // Expenses are negative, but we want positive for display
      final percentage = totalExpenses > 0 ? (amount / totalExpenses).clamp(0.0, 1.0) : 0.0;

      // Find category emoji and color
      final category = state.categories.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => Category(
          name: categoryName,
          emoji: '💰',
          colorValue: 0xFF9E9E9E,
          type: TransactionType.expense,
        ),
      );

      result.add(CategoryData(
        emoji: category.emoji,
        name: categoryName,
        amount: amount.toInt(),
        percentage: percentage,
        color: Color(category.colorValue),
      ));
    }

    // Sort by amount descending
    result.sort((a, b) => b.amount.compareTo(a.amount));

    return result;
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
