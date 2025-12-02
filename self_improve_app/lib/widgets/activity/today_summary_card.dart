import 'package:flutter/material.dart';
import 'package:self_improve_app/services/database_service.dart';

class TodaySummaryCard extends StatefulWidget {
  const TodaySummaryCard({super.key});

  @override
  State<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<TodaySummaryCard> {
  final _databaseService = DatabaseService.instance;
  int _totalSeconds = 0;
  int _sessionCount = 0;
  Map<String, int> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    try {
      final now = DateTime.now();
      final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final sessions = await _databaseService.getFocusSessions(date: dateString);
      
      int total = 0;
      final Map<String, int> categoryTotals = {};
      
      for (final session in sessions) {
        total += session.duration;
        categoryTotals[session.category] = (categoryTotals[session.category] ?? 0) + session.duration;
      }
      
      if (mounted) {
        setState(() {
          _totalSeconds = total;
          _sessionCount = sessions.length;
          _categoryTotals = categoryTotals;
        });
      }
    } catch (e) {
      // Handle error gracefully - table might not exist yet
      print('Error loading today data: $e');
      if (mounted) {
        setState(() {
          _totalSeconds = 0;
          _sessionCount = 0;
          _categoryTotals = {};
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Today's Focus",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadTodayData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${_formatDuration(_totalSeconds)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sessions: $_sessionCount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_categoryTotals.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'By Category:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              ..._categoryTotals.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_getCategoryEmoji(entry.key)} ${entry.key}:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(entry.value),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

