import 'package:flutter/material.dart';

class ScheduledReportsWidget extends StatelessWidget {
  const ScheduledReportsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ScheduledReportItem(
              title: 'Weekly Financial Summary',
              schedule: 'Every Monday, 9:00 AM',
              format: 'PDF',
              isEnabled: true,
              onToggle: (value) {},
              onEdit: () {},
            ),
            const Divider(height: 24),
            _ScheduledReportItem(
              title: 'Monthly Goals Progress',
              schedule: 'First day of month, 8:00 AM',
              format: 'PDF',
              isEnabled: true,
              onToggle: (value) {},
              onEdit: () {},
            ),
            const Divider(height: 24),
            _ScheduledReportItem(
              title: 'Quarterly Review',
              schedule: 'End of quarter',
              format: 'Excel',
              isEnabled: false,
              onToggle: (value) {},
              onEdit: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduledReportItem extends StatelessWidget {
  final String title;
  final String schedule;
  final String format;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _ScheduledReportItem({
    required this.title,
    required this.schedule,
    required this.format,
    required this.isEnabled,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                schedule,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  format,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
        Switch(
          value: isEnabled,
          onChanged: onToggle,
        ),
      ],
    );
  }
}
