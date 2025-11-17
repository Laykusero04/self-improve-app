import 'package:flutter/material.dart';
import '../widgets/activity/timer_widget.dart';
import '../widgets/app_drawer.dart';
import 'app_selection_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: 'Select apps to block',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const TimerWidget(),
    );
  }
}
