import 'package:flutter/material.dart';

class DailyAISummaryWidget extends StatelessWidget {
  const DailyAISummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.tertiaryContainer,
              Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🧭',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LifeLens AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              '"Great work this week! 📈\n\nYour financial health score improved by 15%. You\'re saving more and spending wisely. Your productivity is up 20% compared to last week.\n\nKeep up the momentum! 🚀"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer.withOpacity(0.9),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.chat_outlined,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  label: Text(
                    'Chat with AI',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.share_outlined,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  label: Text(
                    'Share',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
