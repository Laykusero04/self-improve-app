import 'dart:typed_data';

class AppInfo {
  final String packageName;
  final String appName;
  final bool isBlocked;
  final Uint8List? icon;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.isBlocked = false,
    this.icon,
  });

  AppInfo copyWith({
    String? packageName,
    String? appName,
    bool? isBlocked,
    Uint8List? icon,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isBlocked: isBlocked ?? this.isBlocked,
      icon: icon ?? this.icon,
    );
  }
}
