import 'package:flutter/material.dart';

class SessionsListWidget extends StatelessWidget {
  final String period;

  const SessionsListWidget({
    super.key,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = _getSessions(period);

    return Column(
      children: sessions.map((session) => _SessionCard(session: session)).toList(),
    );
  }

  List<SessionData> _getSessions(String period) {
    // Mock data - different for each period
    if (period == 'today') {
      return [
        SessionData(
          emoji: '🎨',
          title: 'Design Work',
          startTime: '09:00 AM',
          endTime: '11:30 AM',
          duration: '2h 30m',
          percentageOfAvg: 83,
        ),
        SessionData(
          emoji: '💻',
          title: 'Coding',
          startTime: '02:00 PM',
          endTime: '05:00 PM',
          duration: '3h 00m',
          percentageOfAvg: 100,
        ),
        SessionData(
          emoji: '📚',
          title: 'Learning',
          startTime: '07:00 PM',
          endTime: '08:00 PM',
          duration: '1h 00m',
          percentageOfAvg: 67,
        ),
      ];
    } else if (period == 'week') {
      return [
        SessionData(
          emoji: '💻',
          title: 'Coding',
          startTime: 'Mon',
          endTime: '18h total',
          duration: '18h',
          percentageOfAvg: 100,
        ),
        SessionData(
          emoji: '🎨',
          title: 'Design Work',
          startTime: 'Tue-Thu',
          endTime: '12h total',
          duration: '12h',
          percentageOfAvg: 80,
        ),
        SessionData(
          emoji: '📚',
          title: 'Learning',
          startTime: 'Fri',
          endTime: '5h total',
          duration: '5h',
          percentageOfAvg: 65,
        ),
      ];
    } else {
      return [
        SessionData(
          emoji: '💻',
          title: 'Coding',
          startTime: 'Week 1-4',
          endTime: '72h total',
          duration: '72h',
          percentageOfAvg: 100,
        ),
        SessionData(
          emoji: '🎨',
          title: 'Design Work',
          startTime: 'Week 1-4',
          endTime: '48h total',
          duration: '48h',
          percentageOfAvg: 85,
        ),
        SessionData(
          emoji: '📚',
          title: 'Learning',
          startTime: 'Week 1-4',
          endTime: '20h total',
          duration: '20h',
          percentageOfAvg: 70,
        ),
      ];
    }
  }
}

class _SessionCard extends StatelessWidget {
  final SessionData session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  session.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Time Info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session.startTime} - ${session.endTime}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Duration
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${session.duration}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: session.percentageOfAvg / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForPercentage(session.percentageOfAvg, context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${session.percentageOfAvg}% of avg',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(int percentage, BuildContext context) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Colors.orange;
    }
  }
}

class SessionData {
  final String emoji;
  final String title;
  final String startTime;
  final String endTime;
  final String duration;
  final int percentageOfAvg;

  SessionData({
    required this.emoji,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.percentageOfAvg,
  });
}
