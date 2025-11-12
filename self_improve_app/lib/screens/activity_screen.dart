import 'package:flutter/material.dart';
import '../widgets/activity/timer_widget.dart';
import '../widgets/app_drawer.dart';

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
      ),
      drawer: const AppDrawer(),
      body: const TimerWidget(),
    );
  }
}
