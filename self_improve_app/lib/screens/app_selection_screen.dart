import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart' as installed;
import '../models/app_info.dart' as model;
import '../services/app_blocker_service.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final _appBlockerService = AppBlockerService();
  List<model.AppInfo> _apps = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all installed apps excluding system apps
      final installedApps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        excludeNonLaunchableApps: true,
        withIcon: true,
      );

      // Get currently blocked apps
      final blockedApps = _appBlockerService.blockedApps;

      // Convert to our AppInfo model
      final appList = installedApps.map((installed.AppInfo app) {
        return model.AppInfo(
          packageName: app.packageName,
          appName: app.name,
          isBlocked: blockedApps.contains(app.packageName),
          icon: app.icon,
        );
      }).toList();

      // Sort: blocked apps first, then alphabetically
      appList.sort((a, b) {
        if (a.isBlocked != b.isBlocked) {
          return a.isBlocked ? -1 : 1;
        }
        return a.appName.toLowerCase().compareTo(b.appName.toLowerCase());
      });

      setState(() {
        _apps = appList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load installed apps: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleApp(int index) async {
    final app = _apps[index];
    final newBlockedState = !app.isBlocked;

    if (newBlockedState) {
      await _appBlockerService.addBlockedApp(app.packageName);
    } else {
      await _appBlockerService.removeBlockedApp(app.packageName);
    }

    setState(() {
      _apps[index] = app.copyWith(isBlocked: newBlockedState);

      // Re-sort the list
      _apps.sort((a, b) {
        if (a.isBlocked != b.isBlocked) {
          return a.isBlocked ? -1 : 1;
        }
        return a.appName.compareTo(b.appName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockedCount = _apps.where((app) => app.isBlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps to Block'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh app list',
              onPressed: _loadInstalledApps,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading installed apps...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadInstalledApps,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Summary card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.block,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$blockedCount of ${_apps.length} app${_apps.length != 1 ? 's' : ''} selected to block',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // App list
                    Expanded(
                      child: _apps.isEmpty
                          ? const Center(
                              child: Text('No apps found'),
                            )
                          : ListView.builder(
                              itemCount: _apps.length,
                              itemBuilder: (context, index) {
                                final app = _apps[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: CheckboxListTile(
                                    value: app.isBlocked,
                                    onChanged: (value) => _toggleApp(index),
                                    title: Text(
                                      app.appName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      app.packageName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    secondary: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: app.isBlocked
                                            ? Theme.of(context)
                                                .colorScheme
                                                .errorContainer
                                                .withValues(alpha: 0.3)
                                            : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: app.icon != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.memory(
                                                app.icon!,
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : Icon(
                                              app.isBlocked
                                                  ? Icons.block
                                                  : Icons.apps,
                                              color: app.isBlocked
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onErrorContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
