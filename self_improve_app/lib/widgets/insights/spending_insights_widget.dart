import 'package:flutter/material.dart';

class SpendingInsightsWidget extends StatelessWidget {
  const SpendingInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Attention Needed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Food spending is 30% above your target this month.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),

            Text(
              'Recommendation:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            _RecommendationItem(text: 'Reduce dining out by 20%'),
            const SizedBox(height: 8),
            _RecommendationItem(text: 'Set weekly food budget'),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Set Budget'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Dismiss'),
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

class _RecommendationItem extends StatelessWidget {
  final String text;

  const _RecommendationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.circle,
            size: 6,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
