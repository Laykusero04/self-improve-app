import 'package:flutter/material.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  bool _isExpanded = true;
  bool _isRunning = false;
  bool _isPaused = false;
  int _seconds = 0;
  Timer? _timer;
  String _currentTask = 'Design Work';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Header
            ListTile(
              leading: Icon(
                Icons.timer,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'Timer Widget',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              trailing: IconButton(
                icon: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),

            // Collapsible Content
            if (_isExpanded) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Task Name
                    Row(
                      children: [
                        const Text(
                          '🎨',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _currentTask,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Time Display
                    Text(
                      _formatTime(_seconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontFamily: 'monospace',
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isRunning || _isPaused)
                          ElevatedButton.icon(
                            onPressed: _startTimer,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(_isPaused ? 'Resume' : 'Start'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        if (_isRunning && !_isPaused) ...[
                          ElevatedButton.icon(
                            onPressed: _pauseTimer,
                            icon: const Icon(Icons.pause),
                            label: const Text('Pause'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (_isRunning || _isPaused)
                          OutlinedButton.icon(
                            onPressed: _stopTimer,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            // TODO: Add note to session
                          },
                          icon: Icon(
                            Icons.note_add,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
