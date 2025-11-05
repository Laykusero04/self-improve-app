import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Goal _currentGoal;
  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentGoal = widget.goal;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Reload goal to get latest data
    final latestGoal = await DatabaseService.instance.getGoal(_currentGoal.id!);
    if (latestGoal != null) {
      _currentGoal = latestGoal;
    }

    _entries = await DatabaseService.instance.getGoalEntries(_currentGoal.id!);
    _notes = await DatabaseService.instance.getGoalNotes(_currentGoal.id!);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGoal.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Progress'),
            Tab(text: 'Notes'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProgressTab(),
                _buildNotesTab(),
                _buildAboutTab(),
              ],
            ),
    );
  }

  Widget _buildProgressTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics cards
          _buildStatisticsCards(),
          const SizedBox(height: 24),

          // Charts
          _buildChartsSection(),
          const SizedBox(height: 24),

          // Calendar/History
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    // Calculate statistics from entries
    final completeEntries = _entries.where((e) => e['entryType'] == 'complete').length;
    final failedEntries = _entries.where((e) => e['entryType'] == 'failed').length;
    final skippedEntries = _entries.where((e) => e['entryType'] == 'skipped').length;
    final totalEntries = _entries.length;

    // Calculate streak
    final streak = _calculateCurrentStreak();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: 'COMPLETE',
                value: '$completeEntries ${_currentGoal.type == GoalType.activity ? 'days' : 'times'}',
                subtitle: completeEntries > 0 ? '+${completeEntries}d' : '---',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.cancel,
                iconColor: Colors.red,
                title: 'FAILED',
                value: '$failedEntries ${_currentGoal.type == GoalType.activity ? 'days' : 'times'}',
                subtitle: '---',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.fast_forward,
                iconColor: Colors.orange,
                title: 'SKIPPED',
                value: '$skippedEntries ${_currentGoal.type == GoalType.activity ? 'days' : 'times'}',
                subtitle: '---',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.analytics,
                iconColor: Colors.blue,
                title: 'TOTAL',
                value: '$totalEntries times',
                subtitle: totalEntries > 0 ? '+${totalEntries} times' : '---',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Streaks section
        _buildStreaksCard(streak),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitle.startsWith('+')
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksCard(int currentStreak) {
    final dateFormat = DateFormat('MMM d');
    final now = DateTime.now();

    // Get dates for streak display
    String startDate = '';
    String endDate = dateFormat.format(now);

    if (_entries.isNotEmpty && currentStreak > 0) {
      final streakStartDate = now.subtract(Duration(days: currentStreak - 1));
      startDate = dateFormat.format(streakStartDate);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streaks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                startDate.isNotEmpty ? startDate : '---',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _currentGoal.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$currentStreak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                endDate,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateCurrentStreak() {
    if (_entries.isEmpty) return 0;

    // Sort entries by date (newest first)
    final sortedEntries = List<Map<String, dynamic>>.from(_entries);
    sortedEntries.sort((a, b) =>
      (b['entryDate'] as int).compareTo(a['entryDate'] as int)
    );

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    for (final entry in sortedEntries) {
      final entryDate = DateTime.fromMillisecondsSinceEpoch(entry['entryDate'] as int);
      final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);

      if (entry['entryType'] == 'complete') {
        if (entryDay.isAtSameMomentAs(checkDate) ||
            entryDay.isBefore(checkDate) && checkDate.difference(entryDay).inDays <= 1) {
          streak++;
          checkDate = entryDay.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly average chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MONTHLY AVERAGE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('DAY'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('WEEK'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'MONTH',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('YEAR'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_entries.length} times',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: _buildMonthlyChart(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Consistency chart
        _buildConsistencyChart(),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    // Group entries by month
    final monthlyData = <String, int>{};

    for (final entry in _entries) {
      if (entry['entryType'] == 'complete') {
        final date = DateTime.fromMillisecondsSinceEpoch(entry['entryDate'] as int);
        final monthKey = DateFormat('MMM').format(date);
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
      }
    }

    if (monthlyData.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (monthlyData.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = monthlyData.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          monthlyData.length,
          (index) {
            final count = monthlyData.values.elementAt(index);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: _currentGoal.color,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConsistencyChart() {
    final completeEntries = _entries.where((e) => e['entryType'] == 'complete').length;
    final totalDays = DateTime.now().difference(_currentGoal.startDate).inDays + 1;
    final consistency = totalDays > 0 ? (completeEntries / totalDays * 100).round() : 0;

    final dateFormat = DateFormat('MMM d');
    final startDateStr = dateFormat.format(_currentGoal.startDate);
    final endDateStr = 'TODAY';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consistency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$startDateStr - $endDateStr',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$consistency%',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _buildConsistencyLineChart(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '30D',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text('60D'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('90D'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('120D'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyLineChart() {
    // Calculate daily consistency for last 30 days
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      // Count entries up to this date
      final entriesUpToDate = _entries.where((e) {
        final entryDate = DateTime.fromMillisecondsSinceEpoch(e['entryDate'] as int);
        return entryDate.isBefore(dateKey.add(const Duration(days: 1))) &&
               e['entryType'] == 'complete';
      }).length;

      final daysFromStart = dateKey.difference(_currentGoal.startDate).inDays + 1;
      final consistency = daysFromStart > 0 ? (entriesUpToDate / daysFromStart * 100) : 0;

      spots.add(FlSpot((29 - i).toDouble(), consistency.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _currentGoal.color,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _currentGoal.color.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No history yet. Start logging your progress!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._entries.map((entry) {
          final date = DateTime.fromMillisecondsSinceEpoch(entry['entryDate'] as int);
          final dateStr = DateFormat('MMM d, yyyy').format(date);
          final timeStr = DateFormat('h:mm a').format(date);
          final entryType = entry['entryType'] as String;
          final amount = entry['amount'] as double;
          final note = entry['note'] as String?;

          IconData icon;
          Color color;
          String title;

          switch (entryType) {
            case 'complete':
              icon = Icons.check_circle;
              color = Colors.green;
              title = 'Completed';
              break;
            case 'failed':
              icon = Icons.cancel;
              color = Colors.red;
              title = 'Failed';
              break;
            case 'skipped':
              icon = Icons.fast_forward;
              color = Colors.orange;
              title = 'Skipped';
              break;
            default:
              icon = Icons.circle;
              color = Colors.grey;
              title = 'Entry';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(icon, color: color),
              title: Text(title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$dateStr at $timeStr'),
                  if (_currentGoal.type == GoalType.financial)
                    Text('Amount: ₱${amount.toStringAsFixed(2)}'),
                  if (note != null && note.isNotEmpty)
                    Text('Note: $note', style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        Expanded(
          child: _notes.isEmpty
              ? Center(
                  child: Text(
                    'No notes yet. Add your first note!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final createdAt = DateTime.fromMillisecondsSinceEpoch(note['createdAt'] as int);
                    final dateStr = DateFormat('MMM d, yyyy h:mm a').format(createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(note['content'] as String),
                        subtitle: Text(dateStr),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteNote(note['id'] as int),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await DatabaseService.instance.insertGoalNote(
                  goalId: _currentGoal.id!,
                  content: controller.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(int noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteGoalNote(noteId);
      _loadData();
    }
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Goal Information',
          children: [
            _buildInfoRow('Title', _currentGoal.title),
            _buildInfoRow('Type', _currentGoal.type == GoalType.activity ? 'Activity' : 'Saving'),
            if (_currentGoal.type == GoalType.financial)
              _buildInfoRow('Target Amount', '₱${_currentGoal.target.toStringAsFixed(0)}'),
            if (_currentGoal.type == GoalType.activity)
              _buildInfoRow('Times per Day', '${_currentGoal.timesPerDay}'),
            _buildInfoRow('Status', _currentGoal.status.name.toUpperCase()),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Schedule',
          children: [
            _buildInfoRow('Repeat', _getRepeatTypeText()),
            if (_currentGoal.repeatType == RepeatType.daily && _currentGoal.selectedDaysOfWeek.isNotEmpty)
              _buildInfoRow('Days', _getSelectedDaysText()),
            if (_currentGoal.repeatType == RepeatType.interval)
              _buildInfoRow('Every', '${_currentGoal.intervalDays} days'),
            if (_currentGoal.reminderTime != null)
              _buildInfoRow('Reminder', _currentGoal.reminderTime!.format(context)),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Dates',
          children: [
            _buildInfoRow('Start Date', DateFormat('MMM d, yyyy').format(_currentGoal.startDate)),
            if (_currentGoal.targetDate != null)
              _buildInfoRow('Target Date', DateFormat('MMM d, yyyy').format(_currentGoal.targetDate!)),
            if (_currentGoal.completedDate != null)
              _buildInfoRow('Completed Date', DateFormat('MMM d, yyyy').format(_currentGoal.completedDate!)),
            _buildInfoRow('Created At', DateFormat('MMM d, yyyy').format(_currentGoal.createdAt)),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Progress',
          children: [
            _buildInfoRow('Current', _currentGoal.type == GoalType.financial
                ? '₱${_currentGoal.current.toStringAsFixed(0)}'
                : '${_currentGoal.current.toStringAsFixed(0)} times'),
            _buildInfoRow('Target', _currentGoal.type == GoalType.financial
                ? '₱${_currentGoal.target.toStringAsFixed(0)}'
                : '${_currentGoal.target.toStringAsFixed(0)} times'),
            _buildInfoRow('Progress', '${(_currentGoal.progress * 100).toStringAsFixed(1)}%'),
            if (_currentGoal.type == GoalType.financial)
              _buildInfoRow('Remaining', '₱${_currentGoal.remaining.toStringAsFixed(0)}'),
          ],
        ),
        if (_currentGoal.checklistItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Checklist',
            children: _currentGoal.checklistItems.map((item) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_box_outline_blank, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRepeatTypeText() {
    switch (_currentGoal.repeatType) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.interval:
        return 'Every ${_currentGoal.intervalDays} days';
    }
  }

  String _getSelectedDaysText() {
    if (_currentGoal.selectedDaysOfWeek.isEmpty) return 'Every day';

    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDays = _currentGoal.selectedDaysOfWeek.toList()..sort();
    return selectedDays.map((d) => days[d]).join(', ');
  }
}
