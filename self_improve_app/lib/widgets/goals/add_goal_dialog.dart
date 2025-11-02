import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/goals/goals_bloc.dart';
import '../../bloc/goals/goals_event.dart';
import '../../models/goal.dart';

class AddGoalDialog extends StatefulWidget {
  final Goal? goal;

  const AddGoalDialog({
    super.key,
    this.goal,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _currentController;
  late TextEditingController _targetController;
  late TextEditingController _emojiController;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90));

  // Popular emoji options
  final List<String> _emojiOptions = [
    '🎯', '💰', '🏖️', '💻', '🚗', '🏠', '📚', '🎓',
    '✈️', '🎮', '🎸', '🏋️', '💍', '⌚', '👟', '👜',
    '📱', '💻', '🎁', '🍕', '☕', '🍔', '🎪', '🎭',
  ];

  String _selectedEmoji = '🎯';

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      final g = widget.goal!;
      _titleController = TextEditingController(text: g.title);
      _currentController = TextEditingController(text: g.current.toString());
      _targetController = TextEditingController(text: g.target.toString());
      _emojiController = TextEditingController(text: g.emoji);
      _selectedDate = g.targetDate;
      _selectedEmoji = g.emoji;
    } else {
      _titleController = TextEditingController();
      _currentController = TextEditingController(text: '0');
      _targetController = TextEditingController();
      _emojiController = TextEditingController(text: '🎯');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final current = double.parse(_currentController.text);
      final target = double.parse(_targetController.text);

      if (current > target) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current amount cannot be greater than target amount'),
          ),
        );
        return;
      }

      final goal = Goal(
        id: widget.goal?.id,
        title: _titleController.text.trim(),
        emoji: _selectedEmoji,
        current: current,
        target: target,
        targetDate: _selectedDate,
        status: widget.goal?.status ?? GoalStatus.active,
        completedDate: widget.goal?.completedDate,
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
      );

      if (widget.goal != null) {
        context.read<GoalsBloc>().add(GoalUpdated(goal));
      } else {
        context.read<GoalsBloc>().add(GoalAdded(goal));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.goal != null ? 'Edit Goal' : 'Add Goal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Emoji Selection
              Text(
                'Choose Emoji',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojiOptions.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                        _emojiController.text = emoji;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedEmoji == emoji
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: _selectedEmoji == emoji ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedEmoji == emoji
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Custom Emoji Input
              TextFormField(
                controller: _emojiController,
                decoration: const InputDecoration(
                  labelText: 'Or Enter Custom Emoji',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _selectedEmoji = value;
                    });
                  }
                },
                maxLength: 2,
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Amount
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '₱',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter target amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Current Amount
              TextFormField(
                controller: _currentController,
                decoration: const InputDecoration(
                  labelText: 'Current Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.savings),
                  prefixText: '₱',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter current amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveGoal,
                    child: Text(widget.goal != null ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

