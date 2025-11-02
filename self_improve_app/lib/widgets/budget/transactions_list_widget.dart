import 'package:flutter/material.dart';

class TransactionsListWidget extends StatelessWidget {
  final int? limit;

  const TransactionsListWidget({
    super.key,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final allTransactions = [
      // Today
      TransactionGroup(
        date: 'Today',
        transactions: [
          TransactionData(
            emoji: '🍔',
            title: 'Coffee House',
            category: 'Food',
            time: '2:30 PM',
            amount: -5.50,
            isExpense: true,
          ),
          TransactionData(
            emoji: '💰',
            title: 'Salary',
            category: 'Income',
            time: '9:00 AM',
            amount: 1500,
            isExpense: false,
          ),
        ],
      ),
      // Yesterday
      TransactionGroup(
        date: 'Yesterday',
        transactions: [
          TransactionData(
            emoji: '🚗',
            title: 'Gas Station',
            category: 'Transport',
            time: '6:45 PM',
            amount: -45.00,
            isExpense: true,
          ),
          TransactionData(
            emoji: '🛒',
            title: 'Grocery Store',
            category: 'Shopping',
            time: '4:30 PM',
            amount: -85.50,
            isExpense: true,
          ),
          TransactionData(
            emoji: '🎮',
            title: 'Netflix Subscription',
            category: 'Entertainment',
            time: '10:00 AM',
            amount: -15.99,
            isExpense: true,
          ),
        ],
      ),
    ];

    // Apply limit if specified
    final displayGroups = limit != null ? _limitTransactions(allTransactions, limit!) : allTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayGroups.map((group) => _TransactionGroupWidget(group: group)),

        if (limit != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () {},
                child: const Text('View All Transactions →'),
              ),
            ),
          ),
      ],
    );
  }

  List<TransactionGroup> _limitTransactions(List<TransactionGroup> groups, int limit) {
    final List<TransactionGroup> result = [];
    int count = 0;

    for (var group in groups) {
      if (count >= limit) break;

      final remaining = limit - count;
      if (group.transactions.length <= remaining) {
        result.add(group);
        count += group.transactions.length;
      } else {
        result.add(TransactionGroup(
          date: group.date,
          transactions: group.transactions.take(remaining).toList(),
        ));
        count += remaining;
      }
    }

    return result;
  }
}

class _TransactionGroupWidget extends StatelessWidget {
  final TransactionGroup group;

  const _TransactionGroupWidget({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 16),
              const SizedBox(width: 8),
              Text(
                group.date,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
        ...group.transactions.map((transaction) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TransactionCard(transaction: transaction),
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionData transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.title + transaction.time),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.isExpense
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            transaction.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            '${transaction.time} • ${transaction.category}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Text(
            '${transaction.isExpense ? '-' : '+'}₱${transaction.amount.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.isExpense ? Colors.red.shade700 : Colors.green.shade700,
                ),
          ),
        ),
      ),
    );
  }
}

class TransactionGroup {
  final String date;
  final List<TransactionData> transactions;

  TransactionGroup({
    required this.date,
    required this.transactions,
  });
}

class TransactionData {
  final String emoji;
  final String title;
  final String category;
  final String time;
  final double amount;
  final bool isExpense;

  TransactionData({
    required this.emoji,
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    required this.isExpense,
  });
}
