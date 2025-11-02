import 'package:flutter/material.dart';

class ReportTemplatesWidget extends StatelessWidget {
  const ReportTemplatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _TemplateCard(
          icon: Icons.account_balance_wallet,
          title: 'Financial Summary',
          description: 'Income, expenses & savings',
          color: Colors.green,
          onTap: () {},
        ),
        _TemplateCard(
          icon: Icons.flag,
          title: 'Goals Report',
          description: 'Progress & achievements',
          color: Colors.blue,
          onTap: () {},
        ),
        _TemplateCard(
          icon: Icons.timer,
          title: 'Productivity',
          description: 'Time tracking & activities',
          color: Colors.purple,
          onTap: () {},
        ),
        _TemplateCard(
          icon: Icons.school,
          title: 'Skills Report',
          description: 'Learning progress',
          color: Colors.orange,
          onTap: () {},
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
