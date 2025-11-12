import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:self_improve_app/services/app_blocker_service.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  bool _isRunning = false;
  bool _isPaused = false;
  int _seconds = 0;
  Timer? _timer;
  bool _blockApps = false;
  bool _hasPermission = false;
  final _appBlockerService = AppBlockerService();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _appBlockerService.stopBlocking();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    // Check if we have usage stats permission
    final status = await Permission.systemAlertWindow.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'To block distracting apps, this app needs permission to access usage stats and display over other apps.\n\n'
          'This allows the app to:\n'
          '• Monitor which apps are running\n'
          '• Block access to selected apps during focus time\n\n'
          'Would you like to grant this permission?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Open settings to grant permission
      await AppSettings.openAppSettings(type: AppSettingsType.settings);

      // Recheck permission after returning
      await Future.delayed(const Duration(seconds: 1));
      await _checkPermission();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Timer
          CustomPaint(
            size: const Size(200, 200),
            painter: CircleTimerPainter(
              progress: _isRunning ? (_seconds % 60) / 60.0 : 0.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: Text(
                  _formatTime(_seconds),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning || _isPaused)
                IconButton.filled(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 32,
                  padding: const EdgeInsets.all(16),
                ),
              if (_isRunning && !_isPaused)
                IconButton.filled(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause),
                  iconSize: 32,
                  padding: const EdgeInsets.all(16),
                ),
              if (_isRunning || _isPaused) ...[
                const SizedBox(width: 16),
                IconButton.outlined(
                  onPressed: _stopTimer,
                  icon: const Icon(Icons.stop),
                  iconSize: 32,
                  padding: const EdgeInsets.all(16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 48),

          // Block Apps Toggle
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Block Apps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Switch(
                      value: _blockApps,
                      onChanged: _hasPermission
                          ? (value) {
                              setState(() {
                                _blockApps = value;
                                if (value) {
                                  _appBlockerService.startBlocking();
                                } else {
                                  _appBlockerService.stopBlocking();
                                }
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              if (!_hasPermission) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.lock),
                  label: const Text('Grant Permission to Block Apps'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class CircleTimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleTimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
