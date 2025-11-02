import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_event.dart';
import '../../bloc/budget/budget_state.dart';
import '../../models/transaction.dart';
import '../budget/add_transaction_dialog.dart';

class TransactionsListWidget extends StatelessWidget {
  final int? limit;

  const TransactionsListWidget({
    super.key,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state.isLoading && state.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first transaction',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Group transactions by date
        final groupedTransactions = _groupTransactionsByDate(state.transactions);

        // Apply limit if specified
        final displayGroups = limit != null
            ? _limitTransactions(groupedTransactions, limit!)
            : groupedTransactions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...displayGroups.map((group) => _TransactionGroupWidget(group: group)),

            if (limit != null && groupedTransactions.length > displayGroups.length)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () {
                      // Switch to List tab (index 1)
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: const Text('View All Transactions →'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<TransactionGroup> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      String dateLabel;
      if (transactionDate == today) {
        dateLabel = 'Today';
      } else if (transactionDate == yesterday) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel = DateFormat('MMMM d, yyyy').format(transaction.date);
      }

      grouped.putIfAbsent(dateLabel, () => []).add(transaction);
    }

    return grouped.entries.map((entry) {
      return TransactionGroup(
        date: entry.key,
        transactions: entry.value,
      );
    }).toList();
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
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  String _formatCurrency(double amount) {
    return '₱${amount.abs().toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.horizontal,
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Edit (swipe right) - show dialog with bloc provider
          // Get bloc before async operation
          final bloc = context.read<BudgetBloc>();
          // Use Navigator.push to ensure proper context
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: bloc,
              child: AddTransactionDialog(transaction: transaction),
            ),
          );
          return false; // Don't dismiss, dialog handles it
        } else {
          // Delete (swipe left) - show confirmation
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (deleteContext) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text('Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(deleteContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(deleteContext).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ?? false;
          
          return shouldDelete; // Return true to allow dismissal, false to cancel
        }
      },
      onDismissed: (direction) {
        // This is called only after confirmDismiss returns true
        // Delete the transaction when dismissed
        if (direction == DismissDirection.startToEnd) {
          context.read<BudgetBloc>().add(TransactionDeleted(transaction.id!));
        }
      },
      child: InkWell(
        onTap: () {
          // Allow tap to edit
          final bloc = context.read<BudgetBloc>();
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: bloc,
              child: AddTransactionDialog(transaction: transaction),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
              '${_formatTime(transaction.date)} • ${transaction.category}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${transaction.isExpense ? '-' : '+'}${_formatCurrency(transaction.amount)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: transaction.isExpense
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final bloc = context.read<BudgetBloc>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: bloc,
                        child: AddTransactionDialog(transaction: transaction),
                      ),
                    );
                  },
                  tooltip: 'Edit',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionGroup {
  final String date;
  final List<Transaction> transactions;

  TransactionGroup({
    required this.date,
    required this.transactions,
  });
}
