import 'package:flutter/material.dart';

class RecentReportsWidget extends StatelessWidget {
  const RecentReportsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReportFileItem(
          fileName: 'Financial_Report_October_2024.pdf',
          date: 'Oct 31, 2024',
          size: '2.4 MB',
          type: 'PDF',
          icon: Icons.picture_as_pdf,
          color: Colors.red,
          onOpen: () {},
          onShare: () {},
          onDelete: () {},
        ),
        const SizedBox(height: 12),
        _ReportFileItem(
          fileName: 'Goals_Progress_Q3_2024.pdf',
          date: 'Oct 28, 2024',
          size: '1.8 MB',
          type: 'PDF',
          icon: Icons.picture_as_pdf,
          color: Colors.red,
          onOpen: () {},
          onShare: () {},
          onDelete: () {},
        ),
        const SizedBox(height: 12),
        _ReportFileItem(
          fileName: 'Productivity_Weekly_Oct_21.pdf',
          date: 'Oct 21, 2024',
          size: '1.2 MB',
          type: 'PDF',
          icon: Icons.picture_as_pdf,
          color: Colors.red,
          onOpen: () {},
          onShare: () {},
          onDelete: () {},
        ),
        const SizedBox(height: 12),
        _ReportFileItem(
          fileName: 'Full_Data_Export_Oct_15.csv',
          date: 'Oct 15, 2024',
          size: '856 KB',
          type: 'CSV',
          icon: Icons.table_chart,
          color: Colors.green,
          onOpen: () {},
          onShare: () {},
          onDelete: () {},
        ),
        const SizedBox(height: 12),
        _ReportFileItem(
          fileName: 'Skills_Report_September.xlsx',
          date: 'Sep 30, 2024',
          size: '3.1 MB',
          type: 'Excel',
          icon: Icons.grid_on,
          color: Colors.green.shade700,
          onOpen: () {},
          onShare: () {},
          onDelete: () {},
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          child: const Text('View All Reports'),
        ),
      ],
    );
  }
}

class _ReportFileItem extends StatelessWidget {
  final String fileName;
  final String date;
  final String size;
  final String type;
  final IconData icon;
  final Color color;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _ReportFileItem({
    required this.fileName,
    required this.date,
    required this.size,
    required this.type,
    required this.icon,
    required this.color,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.sd_card,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        size,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'open',
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new, size: 18),
                      SizedBox(width: 12),
                      Text('Open'),
                    ],
                  ),
                  onTap: onOpen,
                ),
                PopupMenuItem(
                  value: 'share',
                  child: const Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 12),
                      Text('Share'),
                    ],
                  ),
                  onTap: onShare,
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red.shade700)),
                    ],
                  ),
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
