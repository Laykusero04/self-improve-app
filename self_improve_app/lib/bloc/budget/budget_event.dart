import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class BudgetInitialized extends BudgetEvent {
  final String period;
  
  const BudgetInitialized({this.period = 'This Month'});

  @override
  List<Object> get props => [period];
}

class BudgetPeriodChanged extends BudgetEvent {
  final String period;
  
  const BudgetPeriodChanged(this.period);

  @override
  List<Object> get props => [period];
}

class BudgetCustomDateRangeChanged extends BudgetEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  const BudgetCustomDateRangeChanged({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class BudgetRefreshed extends BudgetEvent {
  final String period;
  
  const BudgetRefreshed({this.period = 'This Month'});

  @override
  List<Object> get props => [period];
}

class TransactionAdded extends BudgetEvent {
  final Transaction transaction;
  
  const TransactionAdded(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class TransactionUpdated extends BudgetEvent {
  final Transaction transaction;
  
  const TransactionUpdated(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class TransactionDeleted extends BudgetEvent {
  final int transactionId;
  
  const TransactionDeleted(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class CategoryAdded extends BudgetEvent {
  final Category category;
  
  const CategoryAdded(this.category);

  @override
  List<Object> get props => [category];
}

class CategoriesLoaded extends BudgetEvent {
  const CategoriesLoaded();
}

