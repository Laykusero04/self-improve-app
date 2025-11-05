import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late TextEditingController _timesPerDayController;
  late TextEditingController _intervalDaysController;
  late TextEditingController _checklistController;
  late TextEditingController _endConditionValueController;

  // Goal Type
  GoalType _selectedType = GoalType.activity;

  // Color
  Color _selectedColor = const Color(0xFF2196F3);
  final List<Color> _colorOptions = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFF44336), // Red
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFFFF5722), // Deep Orange
  ];

  // Schedule
  RepeatType _repeatType = RepeatType.daily;
  Set<int> _selectedDaysOfWeek = {};
  int _intervalDays = 1;
  int _timesPerDay = 1;

  // Reminders
  TimeOfDay? _reminderTime;
  Set<ShowOnPeriod> _showOnPeriods = {
    ShowOnPeriod.morning,
    ShowOnPeriod.afternoon,
    ShowOnPeriod.evening,
  };

  // End Conditions
  EndConditionType _endConditionType = EndConditionType.never;
  DateTime? _endDate;
  int? _endConditionValue;

  // Checklist
  List<String> _checklistItems = [];

  // Dates
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      final g = widget.goal!;
      _titleController = TextEditingController(text: g.title);
      _currentController = TextEditingController(text: g.current.toString());
      _targetController = TextEditingController(text: g.target.toString());
      _selectedType = g.type;
      _selectedColor = g.color;
      _startDate = g.startDate;
      _targetDate = g.targetDate;
      _repeatType = g.repeatType;
      _selectedDaysOfWeek = Set.from(g.selectedDaysOfWeek);
      _intervalDays = g.intervalDays;
      _timesPerDay = g.timesPerDay;
      _reminderTime = g.reminderTime;
      _showOnPeriods = Set.from(g.showOnPeriods);
      _checklistItems = List.from(g.checklistItems);
      _endConditionType = g.endConditionType;
      _endConditionValue = g.endConditionValue;
      if (g.endConditionType == EndConditionType.onDate && g.targetDate != null) {
        _endDate = g.targetDate;
      }
      _timesPerDayController = TextEditingController(text: g.timesPerDay.toString());
      _intervalDaysController = TextEditingController(text: g.intervalDays.toString());
      _checklistController = TextEditingController();
      _endConditionValueController = TextEditingController(
        text: g.endConditionValue?.toString() ?? '',
      );
    } else {
      _titleController = TextEditingController();
      _currentController = TextEditingController(text: '0');
      _targetController = TextEditingController();
      _timesPerDayController = TextEditingController(text: '1');
      _intervalDaysController = TextEditingController(text: '1');
      _checklistController = TextEditingController();
      _endConditionValueController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    _timesPerDayController.dispose();
    _intervalDaysController.dispose();
    _checklistController.dispose();
    _endConditionValueController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      double target = 0;
      double current = 0;

      if (_selectedType == GoalType.financial) {
        current = double.parse(_currentController.text);
        target = double.parse(_targetController.text);
        if (current > target) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current amount cannot be greater than target amount'),
            ),
          );
          return;
        }
      } else {
        // For habits, use times per day as target
        target = _timesPerDay.toDouble();
        current = 0;
      }

      // Calculate end condition value
      int? endConditionValue = _endConditionValue;
      DateTime? finalTargetDate = _targetDate;

      if (_endConditionType == EndConditionType.onDate && _endDate != null) {
        finalTargetDate = _endDate;
        endConditionValue = _endDate!.millisecondsSinceEpoch;
      } else if (_endConditionType != EndConditionType.never &&
          _endConditionType != EndConditionType.onDate) {
        endConditionValue = _endConditionValue ?? 0;
      }

      final goal = Goal(
        id: widget.goal?.id,
        title: _titleController.text.trim(),
        type: _selectedType,
        color: _selectedColor,
        current: current,
        target: target,
        startDate: _startDate,
        targetDate: finalTargetDate,
        status: widget.goal?.status ?? GoalStatus.active,
        completedDate: widget.goal?.completedDate,
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
        repeatType: _repeatType,
        selectedDaysOfWeek: _selectedDaysOfWeek,
        intervalDays: _intervalDays,
        timesPerDay: _timesPerDay,
        reminderTime: _reminderTime,
        showOnPeriods: _showOnPeriods,
        checklistItems: _checklistItems,
        endConditionType: _endConditionType,
        endConditionValue: endConditionValue,
      );

      if (widget.goal != null) {
        context.read<GoalsBloc>().add(GoalUpdated(goal));
      } else {
        context.read<GoalsBloc>().add(GoalAdded(goal));
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isEndDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEndDate ? (_endDate ?? DateTime.now().add(const Duration(days: 90))) : _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _endDate = picked;
          _targetDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  void _addChecklistItem() {
    final text = _checklistController.text.trim();
    if (text.isNotEmpty && !_checklistItems.contains(text)) {
      setState(() {
        _checklistItems.add(text);
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.goal != null ? 'Edit Goal' : 'Create Goal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Goal Type Selection
                      _buildSectionTitle('Goal Type'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              GoalType.activity,
                              'Activity',
                              Icons.repeat,
                              'Track activities',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeButton(
                              GoalType.financial,
                              'Saving',
                              Icons.savings,
                              'Saving goals',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Basic Information
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 8),

                      // Name
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a goal name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Color
                      Text(
                        'Choose Color',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor == color
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: _selectedColor == color
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Target fields (depends on type)
                      if (_selectedType == GoalType.financial) ...[
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
                        const SizedBox(height: 24),
                      ],

                      // Schedule Section
                      _buildSectionTitle('Schedule'),
                      const SizedBox(height: 8),

                      // Repeat Type
                      DropdownButtonFormField<RepeatType>(
                        value: _repeatType,
                        decoration: const InputDecoration(
                          labelText: 'Repeat',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        items: RepeatType.values.map((type) {
                          String label;
                          switch (type) {
                            case RepeatType.daily:
                              label = 'Daily';
                              break;
                            case RepeatType.weekly:
                              label = 'Weekly';
                              break;
                            case RepeatType.monthly:
                              label = 'Monthly';
                              break;
                            case RepeatType.interval:
                              label = 'Every N Days';
                              break;
                          }
                          return DropdownMenuItem(value: type, child: Text(label));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _repeatType = value!;
                            if (_repeatType != RepeatType.daily) {
                              _selectedDaysOfWeek.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Days of Week (for daily)
                      if (_repeatType == RepeatType.daily) ...[
                        Text(
                          'Days of Week',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (int i = 0; i < 7; i++)
                              ChoiceChip(
                                label: Text(_getDayName(i)),
                                selected: _selectedDaysOfWeek.contains(i),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDaysOfWeek.add(i);
                                    } else {
                                      _selectedDaysOfWeek.remove(i);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Interval Days
                      if (_repeatType == RepeatType.interval) ...[
                        TextFormField(
                          controller: _intervalDaysController,
                          decoration: const InputDecoration(
                            labelText: 'Every N Days',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            helperText: 'e.g., Every 3 days',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter number of days';
                            }
                            final days = int.tryParse(value);
                            if (days == null || days < 1) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _intervalDays = int.tryParse(value) ?? 1;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Times Per Day
                      if (_selectedType == GoalType.activity) ...[
                        TextFormField(
                          controller: _timesPerDayController,
                          decoration: const InputDecoration(
                            labelText: 'Times Per Day',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.repeat_one),
                            helperText: 'How many times per day',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter times per day';
                            }
                            final times = int.tryParse(value);
                            if (times == null || times < 1) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _timesPerDay = int.tryParse(value) ?? 1;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Start Date
                      InkWell(
                        onTap: () => _selectDate(context, isEndDate: false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reminders Section
                      _buildSectionTitle('Reminders'),
                      const SizedBox(height: 8),

                      // Reminder Time
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Remind Me At',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notifications),
                            helperText: 'Optional',
                          ),
                          child: Text(
                            _reminderTime != null
                                ? _reminderTime!.format(context)
                                : 'Not set',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Show On Periods
                      Text(
                        'Show On',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ShowOnPeriod.values.map((period) {
                          String label;
                          IconData icon;
                          switch (period) {
                            case ShowOnPeriod.morning:
                              label = 'Morning';
                              icon = Icons.wb_sunny;
                              break;
                            case ShowOnPeriod.afternoon:
                              label = 'Afternoon';
                              icon = Icons.wb_twilight;
                              break;
                            case ShowOnPeriod.evening:
                              label = 'Evening';
                              icon = Icons.nightlight;
                              break;
                          }
                          return FilterChip(
                            label: Text(label),
                            selected: _showOnPeriods.contains(period),
                            avatar: Icon(icon, size: 18),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _showOnPeriods.add(period);
                                } else {
                                  _showOnPeriods.remove(period);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Checklist Section
                      _buildSectionTitle('Checklist (Optional)'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _checklistController,
                              decoration: const InputDecoration(
                                labelText: 'Add checklist item',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.checklist),
                              ),
                              onFieldSubmitted: (_) => _addChecklistItem(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addChecklistItem,
                          ),
                        ],
                      ),
                      if (_checklistItems.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ..._checklistItems.asMap().entries.map((entry) {
                          return ListTile(
                            leading: const Icon(Icons.check_box_outline_blank),
                            title: Text(entry.value),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeChecklistItem(entry.key),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 24),

                      // End Conditions
                      _buildSectionTitle('End Condition'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<EndConditionType>(
                        value: _endConditionType,
                        decoration: const InputDecoration(
                          labelText: 'When does this goal end?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        items: EndConditionType.values.map((type) {
                          String label;
                          switch (type) {
                            case EndConditionType.never:
                              label = 'Never';
                              break;
                            case EndConditionType.onDate:
                              label = 'On a Date';
                              break;
                            case EndConditionType.afterStreaks:
                              label = 'After Streaks';
                              break;
                            case EndConditionType.afterCompletions:
                              label = 'After Completions';
                              break;
                            case EndConditionType.byTotalAmount:
                              label = 'By Total Amount';
                              break;
                          }
                          return DropdownMenuItem(value: type, child: Text(label));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _endConditionType = value!;
                            if (_endConditionType != EndConditionType.onDate) {
                              _endDate = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      if (_endConditionType == EndConditionType.onDate) ...[
                        InkWell(
                          onTap: () => _selectDate(context, isEndDate: true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event),
                            ),
                            child: Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Select end date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else if (_endConditionType == EndConditionType.afterStreaks ||
                          _endConditionType == EndConditionType.afterCompletions ||
                          _endConditionType == EndConditionType.byTotalAmount) ...[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: _endConditionType == EndConditionType.afterStreaks
                                ? 'Number of Streaks'
                                : _endConditionType == EndConditionType.afterCompletions
                                    ? 'Number of Completions'
                                    : 'Total Amount',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.numbers),
                            helperText: _endConditionType == EndConditionType.afterStreaks
                                ? 'End after this many consecutive days'
                                : _endConditionType == EndConditionType.afterCompletions
                                    ? 'End after this many completions'
                                    : 'End when total reaches this amount',
                          ),
                          controller: _endConditionValueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (_endConditionType == EndConditionType.afterStreaks ||
                                _endConditionType == EndConditionType.afterCompletions ||
                                _endConditionType == EndConditionType.byTotalAmount) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a value';
                              }
                              final val = int.tryParse(value);
                              if (val == null || val < 1) {
                                return 'Please enter a valid number';
                              }
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _endConditionValue = int.tryParse(value);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saveGoal,
                    child: Text(widget.goal != null ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildTypeButton(GoalType type, String label, IconData icon, String subtitle) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int day) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[day];
  }
}
