import 'package:flutter/material.dart';
import 'package:self_improve_app/services/database_service.dart';
import 'dart:math' as math;

class WeeklyChartWidget extends StatefulWidget {
  const WeeklyChartWidget({super.key});

  @override
  State<WeeklyChartWidget> createState() => _WeeklyChartWidgetState();
}

class _WeeklyChartWidgetState extends State<WeeklyChartWidget> {
  final _databaseService = DatabaseService.instance;
  Map<String, int> _weeklyData = {};

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    try {
      final now = DateTime.now();
      // Get start of week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      final weeklyTotals = await _databaseService.getWeeklyTotals(weekStart);
      
      if (mounted) {
        setState(() {
          _weeklyData = weeklyTotals;
        });
      }
    } catch (e) {
      // Handle error gracefully - table might not exist yet
      print('Error loading weekly data: $e');
      if (mounted) {
        setState(() {
          _weeklyData = {};
        });
      }
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
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
    // Calculate max value for scaling
    int maxValue = 1;
    if (_weeklyData.values.isNotEmpty) {
      try {
        maxValue = math.max(_weeklyData.values.reduce((a, b) => a > b ? a : b), 1);
      } catch (e) {
        maxValue = 1;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 20),
                const SizedBox(width: 8),
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadWeeklyData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final dateString = _getDateString(index);
                  final value = _weeklyData[dateString] ?? 0;
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
    );
  }
}

