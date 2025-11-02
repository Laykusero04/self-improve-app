import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_state.dart';
import '../../bloc/budget/budget_event.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

class AddTransactionDialog extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionDialog({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController = TextEditingController(text: t.amount.toString());
      _noteController = TextEditingController(text: t.note ?? '');
      _selectedType = t.type;
      _selectedDate = t.date;
      // We'll set category from bloc state
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);
      // Use category name as title
      final transaction = Transaction(
        id: widget.transaction?.id,
        title: _selectedCategory!.name,
        amount: amount,
        category: _selectedCategory!.name,
        type: _selectedType,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        emoji: _selectedCategory!.emoji,
      );

      if (widget.transaction != null) {
        context.read<BudgetBloc>().add(TransactionUpdated(transaction));
      } else {
        context.read<BudgetBloc>().add(TransactionAdded(transaction));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state.categories.isEmpty && state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get filtered categories based on transaction type
        final availableCategories = state.categories.where((c) => c.type == _selectedType);

        // Set default category if not set or if selected category is not in available list
        if (state.categories.isNotEmpty) {
          if (_selectedCategory == null ||
              !availableCategories.contains(_selectedCategory)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  if (widget.transaction != null &&
                      availableCategories.isNotEmpty) {
                    final categoryName = widget.transaction!.category;
                    _selectedCategory = availableCategories.firstWhere(
                      (c) => c.name == categoryName,
                      orElse: () => availableCategories.first,
                    );
                  } else if (availableCategories.isNotEmpty) {
                    _selectedCategory = availableCategories.first;
                  } else {
                    _selectedCategory = null;
                  }
                });
              }
            });
          }
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Type Selection
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Expense'),
                          selected: _selectedType == TransactionType.expense,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = TransactionType.expense;
                                // Reset category so it can be reselected from filtered list
                                _selectedCategory = null;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Income'),
                          selected: _selectedType == TransactionType.income,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = TransactionType.income;
                                // Reset category so it can be reselected from filtered list
                                _selectedCategory = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category (moved to top)
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: availableCategories.isEmpty
                        ? null
                        : availableCategories.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Row(
                                children: [
                                  Text(category.emoji,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 12),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
                    onChanged: (Category? category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Note
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveTransaction,
                        child: Text(widget.transaction != null ? 'Update' : 'Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

