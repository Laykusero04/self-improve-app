import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

class BudgetState extends Equatable {
  final List<Transaction> transactions;
  final List<Category> categories;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final Map<String, double> categoryTotals;
  final String period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool isLoading;
  final String? error;

  const BudgetState({
    this.transactions = const [],
    this.categories = const [],
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.balance = 0.0,
    this.categoryTotals = const {},
    this.period = 'This Month',
    this.customStartDate,
    this.customEndDate,
    this.isLoading = false,
    this.error,
  });

  BudgetState copyWith({
    List<Transaction>? transactions,
    List<Category>? categories,
    double? totalIncome,
    double? totalExpenses,
    double? balance,
    Map<String, double>? categoryTotals,
    String? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool? isLoading,
    String? error,
  }) {
    return BudgetState(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      balance: balance ?? this.balance,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      period: period ?? this.period,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        categories,
        totalIncome,
        totalExpenses,
        balance,
        categoryTotals,
        period,
        customStartDate,
        customEndDate,
        isLoading,
        error,
      ];
}

