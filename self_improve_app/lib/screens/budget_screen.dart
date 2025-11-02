import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/budget/budget_state.dart';
import '../widgets/budget/financial_overview_card.dart';
import '../widgets/budget/category_breakdown_widget.dart';
import '../widgets/budget/transactions_list_widget.dart';
import '../widgets/budget/categories_list_widget.dart';
import '../widgets/app_drawer.dart';
import '../widgets/budget/add_transaction_dialog.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BudgetBloc()..add(const BudgetInitialized(period: 'This Month')),
      child: Builder(
        builder: (context) => _BudgetView(),
      ),
    );
  }
}

class _BudgetView extends StatefulWidget {
  const _BudgetView();

  @override
  State<_BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<_BudgetView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTransactionDialog() {
    final bloc = context.read<BudgetBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const AddTransactionDialog(),
      ),
    );
  }

  void _showCustomDateRangeDialog(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, 1, 1);
    final lastDate = now;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      helpText: 'Select Date Range',
      cancelText: 'Cancel',
      confirmText: 'Apply',
    );

    if (picked != null) {
      final startDate = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      final endDate = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );

      context.read<BudgetBloc>().add(
        BudgetCustomDateRangeChanged(
          startDate: startDate,
          endDate: endDate,
        ),
      );
    } else {
      // User cancelled - don't change anything, dropdown will revert
      // The bloc state remains unchanged
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            const Text('Budget'),
            const SizedBox(width: 8),
            Text(
              '💰',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Date Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                  Expanded(
                    child: BlocBuilder<BudgetBloc, BudgetState>(
                      builder: (context, state) {
                        String displayPeriod = state.period;
                        if (state.period == 'Custom' && state.customStartDate != null && state.customEndDate != null) {
                          final start = state.customStartDate!;
                          final end = state.customEndDate!;
                          displayPeriod = '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
                        }
                        
                        return DropdownButton<String>(
                          value: state.period,
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: Text(displayPeriod),
                          items: [
                            'This Week',
                            'This Month',
                            'Last Month',
                            'This Year',
                            'Custom',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              if (newValue == 'Custom') {
                                _showCustomDateRangeDialog(context);
                              } else {
                                context.read<BudgetBloc>().add(BudgetPeriodChanged(newValue));
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Financial Overview Card
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FinancialOverviewCard(),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.bar_chart), text: 'Chart'),
                Tab(icon: Icon(Icons.list), text: 'List'),
                Tab(icon: Icon(Icons.category), text: 'Categories'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Chart Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CategoryBreakdownWidget(),
                      const SizedBox(height: 24),
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      const TransactionsListWidget(limit: 5),
                    ],
                  ),
                ),

                // List Tab
                const SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: TransactionsListWidget(),
                ),

                // Categories Tab
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CategoriesListWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
