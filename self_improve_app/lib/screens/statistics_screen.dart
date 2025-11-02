import 'package:flutter/material.dart';
import '../widgets/statistics/overview_stats_widget.dart';
import '../widgets/statistics/financial_stats_widget.dart';
import '../widgets/statistics/productivity_stats_widget.dart';
import '../widgets/statistics/goals_stats_widget.dart';
import '../widgets/app_drawer.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            const Text('Statistics'),
            const SizedBox(width: 8),
            Text(
              '📊',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              // TODO: Export statistics
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Share statistics
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Period Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: 1,
                ),
              ),
            ),
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
                      'This Quarter',
                      'This Year',
                      'All Time',
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

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Financial'),
              Tab(text: 'Productivity'),
              Tab(text: 'Goals'),
            ],
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Overview Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: OverviewStatsWidget(),
                ),

                // Financial Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: FinancialStatsWidget(),
                ),

                // Productivity Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: ProductivityStatsWidget(),
                ),

                // Goals Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: GoalsStatsWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
