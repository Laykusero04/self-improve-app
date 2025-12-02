import 'package:flutter/material.dart';
import 'package:self_improve_app/services/database_service.dart';
import 'package:self_improve_app/models/focus_session.dart';
import 'dart:math' as math;

class FocusStatsScreen extends StatefulWidget {
  const FocusStatsScreen({super.key});

  @override
  State<FocusStatsScreen> createState() => _FocusStatsScreenState();
}

class _FocusStatsScreenState extends State<FocusStatsScreen> {
  final _databaseService = DatabaseService.instance;
  int _todayTotal = 0;
  int _weekTotal = 0;
  Map<String, int> _categoryTotals = {};
  List<FocusSession> _recentSessions = [];
  Map<String, int> _weeklyData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadTodayTotal(),
      _loadWeekTotal(),
      _loadCategoryTotals(),
      _loadRecentSessions(),
      _loadWeeklyData(),
    ]);
  }

  Future<void> _loadTodayTotal() async {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final total = await _databaseService.getTotalDurationForDate(dateString);
    if (mounted) {
      setState(() {
        _todayTotal = total;
      });
    }
  }

  Future<void> _loadWeekTotal() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final total = await _databaseService.getTotalDurationForRange(weekStart, weekEnd);
    if (mounted) {
      setState(() {
        _weekTotal = total;
      });
    }
  }

  Future<void> _loadCategoryTotals() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final totals = await _databaseService.getCategoryTotalsForRange(weekStart, weekEnd);
    if (mounted) {
      setState(() {
        _categoryTotals = totals;
      });
    }
  }

  Future<void> _loadRecentSessions() async {
    final sessions = await _databaseService.getFocusSessions();
    if (mounted) {
      setState(() {
        _recentSessions = sessions.take(20).toList();
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weeklyTotals = await _databaseService.getWeeklyTotals(weekStart);
    if (mounted) {
      setState(() {
        _weeklyData = weeklyTotals;
      });
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Work':
        return '💼';
      case 'Study':
        return '📚';
      case 'Exercise':
        return '🏋️';
      case 'Reading':
        return '📖';
      default:
        return '📝';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (sessionDate == today) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getDayName(int dayOffset) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final targetDate = startOfWeek.add(Duration(days: dayOffset));
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[targetDate.weekday - 1];
  }

  String _getDateString(int dayOffset) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final targetDate = startOfWeek.add(Duration(days: dayOffset));
    return '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(_todayTotal),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This Week',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(_weekTotal),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Weekly Chart
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timeline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Weekly Trend',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: _weeklyData.isEmpty
                            ? Center(
                                child: Text(
                                  'No data for this week',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(7, (index) {
                                  final dateString = _getDateString(index);
                                  final value = _weeklyData[dateString] ?? 0;
                                  final maxValue = _weeklyData.values.isEmpty
                                      ? 1
                                      : math.max(_weeklyData.values.reduce((a, b) => a > b ? a : b), 1);
                                  final height = maxValue > 0 ? (value / maxValue) * 140 : 0.0;

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _formatDuration(value),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 9,
                                                  ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            height: height,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary,
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _getDayName(index),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Breakdown
              if (_categoryTotals.isNotEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'By Category (This Week)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...(_categoryTotals.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                            .map((entry) {
                              final percentage = _weekTotal > 0
                                  ? (entry.value / _weekTotal * 100).toStringAsFixed(0)
                                  : '0';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${_getCategoryEmoji(entry.key)} ${entry.key}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${_formatDuration(entry.value)} ($percentage%)',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: _weekTotal > 0 ? entry.value / _weekTotal : 0,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Recent Sessions
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Recent Sessions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _recentSessions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'No sessions yet',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentSessions.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final session = _recentSessions[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(_getCategoryEmoji(session.category)),
                                  ),
                                  title: Text(session.category),
                                  subtitle: Text(_formatDateTime(session.startTime)),
                                  trailing: Text(
                                    session.formattedDuration,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

