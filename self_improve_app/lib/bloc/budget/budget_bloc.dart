import 'package:bloc/bloc.dart';
import 'budget_event.dart';
import 'budget_state.dart';
import '../../services/database_service.dart';
import '../../models/transaction.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final DatabaseService _databaseService = DatabaseService.instance;

  BudgetBloc() : super(const BudgetState()) {
    on<BudgetInitialized>(_onBudgetInitialized);
    on<BudgetPeriodChanged>(_onBudgetPeriodChanged);
    on<BudgetCustomDateRangeChanged>(_onBudgetCustomDateRangeChanged);
    on<BudgetRefreshed>(_onBudgetRefreshed);
    on<TransactionAdded>(_onTransactionAdded);
    on<TransactionUpdated>(_onTransactionUpdated);
    on<TransactionDeleted>(_onTransactionDeleted);
    on<CategoryAdded>(_onCategoryAdded);
    on<CategoriesLoaded>(_onCategoriesLoaded);
  }

  (DateTime?, DateTime?) _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (period) {
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = startDate.add(const Duration(days: 6));
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    return (startDate, endDate);
  }

  Future<void> _onBudgetInitialized(
    BudgetInitialized event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    await _loadBudgetData(event.period, emit);
  }

  Future<void> _onBudgetPeriodChanged(
    BudgetPeriodChanged event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      period: event.period,
      customStartDate: null,
      customEndDate: null,
    ));
    await _loadBudgetData(event.period, emit);
  }

  Future<void> _onBudgetCustomDateRangeChanged(
    BudgetCustomDateRangeChanged event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      period: 'Custom',
      customStartDate: event.startDate,
      customEndDate: event.endDate,
    ));
    await _loadBudgetDataWithDates(event.startDate, event.endDate, emit);
  }

  Future<void> _onBudgetRefreshed(
    BudgetRefreshed event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    await _loadBudgetData(state.period, emit);
  }

  Future<void> _loadBudgetData(String period, Emitter<BudgetState> emit) async {
    try {
      // Get date range
      DateTime? startDate;
      DateTime? endDate;
      
      if (period == 'Custom' && state.customStartDate != null && state.customEndDate != null) {
        startDate = state.customStartDate;
        endDate = state.customEndDate;
      } else {
        final dates = _getDateRangeForPeriod(period);
        startDate = dates.$1;
        endDate = dates.$2;
      }

      await _loadBudgetDataWithDates(startDate, endDate, emit, period: period);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _loadBudgetDataWithDates(
    DateTime? startDate,
    DateTime? endDate,
    Emitter<BudgetState> emit, {
    String? period,
  }) async {
    try {
      // Load categories
      final categories = await _databaseService.getCategories();

      // Load transactions
      final transactions = await _databaseService.getTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate totals
      final totalIncome = await _databaseService.getTotalIncome(
        startDate: startDate,
        endDate: endDate,
      );
      final totalExpenses = await _databaseService.getTotalExpenses(
        startDate: startDate,
        endDate: endDate,
      );
      final balance = totalIncome - totalExpenses;

      // Get category totals for expenses only
      final categoryTotals = await _databaseService.getCategoryTotals(
        startDate: startDate,
        endDate: endDate,
        type: TransactionType.expense,
      );

      emit(state.copyWith(
        transactions: transactions,
        categories: categories,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
        categoryTotals: categoryTotals,
        period: period ?? state.period,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onTransactionAdded(
    TransactionAdded event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _databaseService.insertTransaction(event.transaction);
      add(BudgetRefreshed(period: state.period));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onTransactionUpdated(
    TransactionUpdated event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _databaseService.updateTransaction(event.transaction);
      add(BudgetRefreshed(period: state.period));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onTransactionDeleted(
    TransactionDeleted event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _databaseService.deleteTransaction(event.transactionId);
      add(BudgetRefreshed(period: state.period));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCategoryAdded(
    CategoryAdded event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _databaseService.insertCategory(event.category);
      // Reload all categories to ensure state is up to date
      final categories = await _databaseService.getCategories();
      emit(state.copyWith(
        categories: categories,
        error: null,
      ));
    } catch (e) {
      // Handle unique constraint violations
      String errorMessage = e.toString();
      if (errorMessage.contains('UNIQUE constraint failed') ||
          errorMessage.contains('UNIQUE constraint')) {
        errorMessage = 'A category with this name already exists';
      }
      // Emit error but keep existing categories
      emit(state.copyWith(
        error: errorMessage,
      ));
      // Clear error after a short delay
      await Future.delayed(const Duration(seconds: 3));
      if (!isClosed) {
        emit(state.copyWith(error: null));
      }
    }
  }

  Future<void> _onCategoriesLoaded(
    CategoriesLoaded event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final categories = await _databaseService.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

