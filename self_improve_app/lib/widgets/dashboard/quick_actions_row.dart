import 'package:flutter/material.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionButton(
          icon: Icons.attach_money,
          label: 'Add Exp',
          onPressed: () {},
        ),
        _QuickActionButton(
          icon: Icons.play_circle_outline,
          label: 'Start Timer',
          onPressed: () {},
        ),
        _QuickActionButton(
          icon: Icons.flag_outlined,
          label: 'New Goal',
          onPressed: () {},
        ),
        _QuickActionButton(
          icon: Icons.bar_chart,
          label: 'Chart View',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: 28,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
