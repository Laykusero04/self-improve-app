import 'dart:async';
import 'package:flutter/material.dart';

class AppBlockerService {
  static final AppBlockerService _instance = AppBlockerService._internal();
  factory AppBlockerService() => _instance;
  AppBlockerService._internal();

  bool _isBlocking = false;
  Timer? _monitorTimer;
  final List<String> _blockedApps = [
    'com.facebook.katana',
    'com.instagram.android',
    'com.twitter.android',
    'com.snapchat.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.reddit.frontpage',
  ];

  bool get isBlocking => _isBlocking;
  List<String> get blockedApps => List.unmodifiable(_blockedApps);

  /// Start blocking apps
  void startBlocking() {
    if (_isBlocking) return;

    _isBlocking = true;
    debugPrint('App blocking started');

    // Monitor apps every 2 seconds
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkAndBlockApps();
    });
  }

  /// Stop blocking apps
  void stopBlocking() {
    if (!_isBlocking) return;

    _isBlocking = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    debugPrint('App blocking stopped');
  }

  /// Check if any blocked apps are running and show overlay
  void _checkAndBlockApps() {
    // This is a placeholder - actual implementation would require
    // platform-specific code to detect foreground apps
    // For now, we just log that we're monitoring
    debugPrint('Monitoring for blocked apps...');
  }

  /// Add an app to the blocked list
  void addBlockedApp(String packageName) {
    if (!_blockedApps.contains(packageName)) {
      _blockedApps.add(packageName);
    }
  }

  /// Remove an app from the blocked list
  void removeBlockedApp(String packageName) {
    _blockedApps.remove(packageName);
  }

  /// Toggle blocking for an app
  void toggleAppBlock(String packageName) {
    if (_blockedApps.contains(packageName)) {
      removeBlockedApp(packageName);
    } else {
      addBlockedApp(packageName);
    }
  }

  /// Dispose resources
  void dispose() {
    stopBlocking();
  }
}
