import 'package:flutter/material.dart';

class PredictionsWidget extends StatelessWidget {
  const PredictionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '🔮',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Based on your current trends:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Prediction Items
            _PredictionItem(
              icon: Icons.flag,
              text: 'You\'ll reach your goal in 42 days (on track)',
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
            _PredictionItem(
              icon: Icons.account_balance_wallet,
              text: 'Your monthly spending will be ~₱1,350 (15% below target)',
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            _PredictionItem(
              icon: Icons.trending_up,
              text: 'Your productivity is projected to increase by 5% next week',
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('View Full Forecast'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _PredictionItem({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
