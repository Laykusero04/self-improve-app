import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_usage/app_usage.dart';

class AppBlockerService {
  static final AppBlockerService _instance = AppBlockerService._internal();
  factory AppBlockerService() => _instance;
  AppBlockerService._internal() {
    _loadBlockedApps();
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onOverlayDismissed') {
        debugPrint('Overlay dismissed callback received');
        _lastOverlayDismissTime = DateTime.now();
        _lastBlockedApp = null;
      }
    });
  }

  static const String _blockedAppsKey = 'blocked_apps';
  static const MethodChannel _channel = MethodChannel('app_blocker');
  static const String _ownPackageName = 'com.example.self_improve_app';

  bool _isBlocking = false;
  Timer? _monitorTimer;
  final List<String> _blockedApps = [];
  bool _isInitialized = false;
  String? _lastBlockedApp;
  DateTime? _lastOverlayDismissTime;
  static const Duration _dismissCooldown = Duration(seconds: 3);

  bool get isBlocking => _isBlocking;
  List<String> get blockedApps => List.unmodifiable(_blockedApps);

  /// Load blocked apps from persistent storage
  Future<void> _loadBlockedApps() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedApps = prefs.getStringList(_blockedAppsKey);

      if (savedApps != null && savedApps.isNotEmpty) {
        _blockedApps.clear();
        _blockedApps.addAll(savedApps);
      } else {
        // Set default blocked apps if none are saved
        _blockedApps.addAll([
          'com.facebook.katana',
          'com.instagram.android',
          'com.twitter.android',
          'com.snapchat.android',
          'com.zhiliaoapp.musically', // TikTok
          'com.reddit.frontpage',
        ]);
        await _saveBlockedApps();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading blocked apps: $e');
    }
  }

  /// Save blocked apps to persistent storage
  Future<void> _saveBlockedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_blockedAppsKey, _blockedApps);
    } catch (e) {
      debugPrint('Error saving blocked apps: $e');
    }
  }

  /// Start blocking apps
  void startBlocking() {
    if (_isBlocking) return;

    _isBlocking = true;
    debugPrint('App blocking started. Blocked apps: $_blockedApps');

    // Monitor apps every 1 second for faster detection
    _monitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAndBlockApps();
    });
  }

  /// Stop blocking apps
  Future<void> stopBlocking() async {
    if (!_isBlocking) return;

    _isBlocking = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _lastBlockedApp = null;

    // Stop the overlay service
    try {
      await _channel.invokeMethod('stopBlockOverlay');
    } catch (e) {
      debugPrint('Error stopping block overlay: $e');
    }

    debugPrint('App blocking stopped');
  }

  /// Check if any blocked apps are running and show overlay
  Future<void> _checkAndBlockApps() async {
    if (_blockedApps.isEmpty) {
      debugPrint('No apps to block');
      return;
    }

    try {
      // Get current time - check last 1 second for faster detection
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(seconds: 1));

      // Get usage stats for the last 1 second
      final List<AppUsageInfo> infos = await AppUsage().getAppUsage(startDate, endDate);

      if (infos.isEmpty) {
        debugPrint('No app usage info available');
        return;
      }

      // Sort by most recent usage
      infos.sort((a, b) => b.endDate.compareTo(a.endDate));

      // Find the most recently used app that isn't our own app
      // This handles cases where usage stats show our app alongside others
      String? currentApp;
      for (final app in infos) {
        if (app.packageName != _ownPackageName) {
          currentApp = app.packageName;
          break;
        }
      }

      // If only our app is in the list, no need to check for blocking
      if (currentApp == null) {
        debugPrint('Only our app in usage stats, skipping');
        return;
      }

      debugPrint('Current app: $currentApp');

      // Check if the current foreground app is in the blocked list
      if (_blockedApps.contains(currentApp)) {
        debugPrint('🚫 BLOCKED APP DETECTED: $currentApp');

        // Check if we're in cooldown period after dismissal
        if (_lastOverlayDismissTime != null) {
          final timeSinceDismiss = DateTime.now().difference(_lastOverlayDismissTime!);
          if (timeSinceDismiss < _dismissCooldown) {
            debugPrint('In cooldown period, skipping overlay (${timeSinceDismiss.inMilliseconds}ms since dismiss)');
            return;
          }
          _lastOverlayDismissTime = null;
        }

        _lastBlockedApp = currentApp;
        await _showBlockOverlay(currentApp);
      } else {
        // Reset when user switches to a different app
        if (_lastBlockedApp != null) {
          debugPrint('User switched away from blocked app');
          _lastBlockedApp = null;
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking blocked apps: $e');
    }
  }

  /// Show blocking overlay using platform channel
  Future<void> _showBlockOverlay(String packageName) async {
    try {
      await _channel.invokeMethod('showBlockOverlay', {
        'packageName': packageName,
      });
    } catch (e) {
      debugPrint('Error showing block overlay: $e');
    }
  }

  /// Add an app to the blocked list
  Future<void> addBlockedApp(String packageName) async {
    if (!_blockedApps.contains(packageName)) {
      _blockedApps.add(packageName);
      await _saveBlockedApps();
    }
  }

  /// Remove an app from the blocked list
  Future<void> removeBlockedApp(String packageName) async {
    if (_blockedApps.remove(packageName)) {
      await _saveBlockedApps();
    }
  }

  /// Toggle blocking for an app
  Future<void> toggleAppBlock(String packageName) async {
    if (_blockedApps.contains(packageName)) {
      await removeBlockedApp(packageName);
    } else {
      await addBlockedApp(packageName);
    }
  }

  /// Dispose resources
  void dispose() {
    stopBlocking();
  }
}
