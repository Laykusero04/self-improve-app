import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:app_usage/app_usage.dart';

class PermissionsStatusWidget extends StatefulWidget {
  const PermissionsStatusWidget({super.key});

  @override
  State<PermissionsStatusWidget> createState() =>
      _PermissionsStatusWidgetState();
}

class _PermissionsStatusWidgetState extends State<PermissionsStatusWidget> {
  bool _systemAlertWindowGranted = false;
  bool _usageStatsGranted = false;
  bool _isCheckingPermissions = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isCheckingPermissions = true);

    final systemAlertStatus = await Permission.systemAlertWindow.status;

    // Check usage stats permission
    bool hasUsageStats = false;
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 1));
      await AppUsage().getAppUsage(startDate, endDate);
      hasUsageStats = true;
    } catch (e) {
      hasUsageStats = false;
    }

    setState(() {
      _systemAlertWindowGranted = systemAlertStatus.isGranted;
      _usageStatsGranted = hasUsageStats;
      _isCheckingPermissions = false;
    });
  }

  Future<void> _openSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.settings);
    // Recheck after user returns
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissions();
  }

  bool get _allPermissionsGranted =>
      _systemAlertWindowGranted && _usageStatsGranted;

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return const SizedBox.shrink();
    }

    // Show compact version if all permissions are granted
    if (_allPermissionsGranted) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'All permissions granted',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              onPressed: () {
                setState(() => _isExpanded = !_isExpanded);
              },
            ),
          ],
        ),
      );
    }

    // Show warning if permissions are missing
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permissions Required',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () {
                  setState(() => _isExpanded = !_isExpanded);
                },
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Text(
              'To block apps during focus time, this app needs the following permissions:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            _PermissionItem(
              icon: Icons.phone_android,
              title: 'Display over other apps',
              description: 'Required to show blocking screen',
              granted: _systemAlertWindowGranted,
            ),
            const SizedBox(height: 12),
            _PermissionItem(
              icon: Icons.app_settings_alt,
              title: 'Usage Access',
              description: 'Required to detect running apps',
              granted: _usageStatsGranted,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Grant Permissions'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _checkPermissions,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onErrorContainer
                      .withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted
              ? Colors.green
              : Theme.of(context).colorScheme.error,
          size: 24,
        ),
      ],
    );
  }
}
