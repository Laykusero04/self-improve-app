import 'package:flutter/material.dart';
import '../widgets/budget/financial_overview_card.dart';
import '../widgets/budget/category_breakdown_widget.dart';
import '../widgets/budget/transactions_list_widget.dart';
import '../widgets/app_drawer.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

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
            onPressed: () {
              // TODO: Implement add transaction
            },
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
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    underline: const SizedBox(),
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
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
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
                const SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: CategoryBreakdownWidget(showAll: true),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add expense
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
