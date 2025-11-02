import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/reports/export_options_widget.dart';
import '../widgets/reports/report_templates_widget.dart';
import '../widgets/reports/scheduled_reports_widget.dart';
import '../widgets/reports/recent_reports_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  String _selectedFormat = 'PDF';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
            tooltip: 'Help',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Configuration Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Report',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Period',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedPeriod,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                                  DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                                  DropdownMenuItem(value: 'This Quarter', child: Text('This Quarter')),
                                  DropdownMenuItem(value: 'This Year', child: Text('This Year')),
                                  DropdownMenuItem(value: 'Custom', child: Text('Custom Range')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPeriod = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Format',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedFormat,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                                  DropdownMenuItem(value: 'CSV', child: Text('CSV')),
                                  DropdownMenuItem(value: 'Excel', child: Text('Excel')),
                                  DropdownMenuItem(value: 'JSON', child: Text('JSON')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFormat = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download),
                        label: const Text('Generate Report'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Report Templates
            Text(
              'Report Templates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            const ReportTemplatesWidget(),
            const SizedBox(height: 24),

            // Export Options
            Text(
              'Quick Export',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            const ExportOptionsWidget(),
            const SizedBox(height: 24),

            // Scheduled Reports
            Text(
              'Scheduled Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            const ScheduledReportsWidget(),
            const SizedBox(height: 24),

            // Recent Reports
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            const RecentReportsWidget(),
          ],
        ),
      ),
    );
  }
}
