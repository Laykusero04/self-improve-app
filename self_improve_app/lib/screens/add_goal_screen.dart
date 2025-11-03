import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/goals/goals_bloc.dart';
import '../bloc/goals/goals_event.dart';
import '../models/goal.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? goal;

  const AddGoalScreen({
    super.key,
    this.goal,
  });

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late TextEditingController _timesPerDayController;
  late TextEditingController _intervalDaysController;
  late TextEditingController _checklistController;
  late TextEditingController _endConditionValueController;
  
  late TabController _scheduleTabController;

  // Goal Type
  GoalType _selectedType = GoalType.habit;

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
  int _monthlyDay = 1; // Day of month (1-31, or special values like -1 for last day)

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
      // If monthly, intervalDays stores the day of month, otherwise use default
      if (g.repeatType == RepeatType.monthly) {
        _monthlyDay = g.intervalDays; // Store day of month in intervalDays for monthly
      } else {
        _monthlyDay = 1;
      }
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
    
    _scheduleTabController = TabController(length: 3, vsync: this);
    _updateScheduleTabIndex();
    
    _scheduleTabController.addListener(() {
      if (!_scheduleTabController.indexIsChanging) {
        _updateRepeatTypeFromTab();
      }
    });
  }

  @override
  void dispose() {
    _scheduleTabController.dispose();
    _titleController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    _timesPerDayController.dispose();
    _intervalDaysController.dispose();
    _checklistController.dispose();
    _endConditionValueController.dispose();
    super.dispose();
  }
  
  void _updateScheduleTabIndex() {
    switch (_repeatType) {
      case RepeatType.daily:
        _scheduleTabController.index = 0;
        break;
      case RepeatType.monthly:
        _scheduleTabController.index = 1;
        break;
      case RepeatType.interval:
        _scheduleTabController.index = 2;
        break;
      case RepeatType.weekly:
        // Weekly is no longer supported, default to daily
        _scheduleTabController.index = 0;
        _repeatType = RepeatType.daily;
        break;
    }
  }
  
  void _updateRepeatTypeFromTab() {
    switch (_scheduleTabController.index) {
      case 0:
        _repeatType = RepeatType.daily;
        break;
      case 1:
        _repeatType = RepeatType.monthly;
        break;
      case 2:
        _repeatType = RepeatType.interval;
        break;
    }
    setState(() {});
  }
  
  void _showScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                'Schedule',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              // Tabs
              TabBar(
                controller: _scheduleTabController,
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Monthly'),
                  Tab(text: 'Interval'),
                ],
              ),
              const Divider(),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _scheduleTabController,
                  children: [
                    // Daily Tab - key forces rebuild when selection changes
                    _buildDailyScheduleTab(
                      key: ValueKey('daily_${_selectedDaysOfWeek.join(",")}'),
                      setModalState: setModalState,
                    ),
                    // Monthly Tab - key forces rebuild when day changes
                    _buildMonthlyScheduleTab(
                      key: ValueKey('monthly_$_monthlyDay'),
                      setModalState: setModalState,
                    ),
                    // Interval Tab - key forces rebuild when interval changes
                    _buildIntervalScheduleTab(
                      key: ValueKey('interval_$_intervalDays'),
                      setModalState: setModalState,
                    ),
                  ],
                ),
              ),
              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Update tab controller when sheet closes
      _updateRepeatTypeFromTab();
    });
  }
  
  Widget _buildDailyScheduleTab({Key? key, StateSetter? setModalState}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Days of Week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < 7; i++)
                FilterChip(
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
                    // Also update modal state for immediate feedback
                    setModalState?.call(() {});
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                ),
            ],
          ),
          if (_selectedDaysOfWeek.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠ Please select at least one day',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          const SizedBox(height: 24),
          if (_selectedType == GoalType.habit) ...[
            Text(
              'Times Per Day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timesPerDayController,
              decoration: const InputDecoration(
                labelText: 'How many times per day',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat_one),
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
                  setState(() {
                    _timesPerDay = int.tryParse(value) ?? 1;
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMonthlyScheduleTab({Key? key, StateSetter? setModalState}) {
    final now = DateTime.now();
    final focusedDay = DateTime(now.year, now.month, _monthlyDay > 0 && _monthlyDay <= 31 ? _monthlyDay : 1);
    
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Select Day of Month',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        TableCalendar(
          key: ValueKey(_monthlyDay), // Force rebuild when selection changes
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          selectedDayPredicate: (day) {
            if (_monthlyDay == -1) return false;
            return day.day == _monthlyDay;
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _monthlyDay = selectedDay.day;
            });
            // Update modal state for immediate visual feedback
            setModalState?.call(() {});
            // Show immediate feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected: ${selectedDay.day}${_getDaySuffix(selectedDay.day)} of month'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          enabledDayPredicate: (day) {
            // Only allow selecting days from the current month being viewed
            return true;
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              // Highlight if it's the selected day of month - check all days with same number
              if (_monthlyDay != -1 && day.day == _monthlyDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return null;
            },
          ),
        ),
        // Last Day Option
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Last Day of Month'),
                  selected: _monthlyDay == -1,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _monthlyDay = -1;
                      });
                      // Update modal state for immediate visual feedback
                      setModalState?.call(() {});
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        if (_selectedType == GoalType.habit) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Times Per Month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timesPerDayController,
                  decoration: const InputDecoration(
                    labelText: 'How many times per month',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat_one),
                    helperText: 'e.g., 2 times per month',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _timesPerDay = int.tryParse(value) ?? 1;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ],
      ),
    );
  }
  
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
  
  Widget _buildIntervalScheduleTab({Key? key, StateSetter? setModalState}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interval',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [2, 3, 4, 5, 6, 7].map((days) {
              final isSelected = _intervalDays == days;
              return FilterChip(
                label: Text('Every $days days'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _intervalDays = days;
                      _intervalDaysController.text = days.toString();
                    });
                    // Update modal state for immediate visual feedback
                    setModalState?.call(() {});
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              );
            }).toList(),
          ),
          if (_intervalDays < 2 || _intervalDays > 7)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠ Please select an interval (2-7 days)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      // Validate Daily schedule - must select at least one day
      if (_repeatType == RepeatType.daily && _selectedDaysOfWeek.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day of the week for daily schedule'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Validate Interval schedule - must select an interval (should be already set, but double check)
      if (_repeatType == RepeatType.interval && (_intervalDays < 2 || _intervalDays > 7)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an interval (2-7 days) for interval schedule'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      double target = 0;
      double current = 0;

      if (_selectedType == GoalType.saving) {
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
        intervalDays: _repeatType == RepeatType.monthly ? _monthlyDay : _intervalDays,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal != null ? 'Edit Goal' : 'Create Goal'),
        actions: [
          FilledButton(
            onPressed: _saveGoal,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(widget.goal != null ? 'Update' : 'Create'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
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
                      GoalType.habit,
                      'Habit',
                      Icons.repeat,
                      'Track daily habits',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      GoalType.saving,
                      'Saving',
                      Icons.savings,
                      'Save money',
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
              if (_selectedType == GoalType.saving) ...[
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
              
              // Schedule Button
              InkWell(
                onTap: _showScheduleBottomSheet,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: _getScheduleLabel(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.schedule),
                    suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  child: Text(
                    _getScheduleDescription(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),

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
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18),
                        const SizedBox(width: 4),
                        Text(label),
                      ],
                    ),
                    selected: _showOnPeriods.contains(period),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _showOnPeriods.add(period);
                        } else {
                          _showOnPeriods.remove(period);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
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

              // Start Date
              _buildSectionTitle('Start Date'),
              const SizedBox(height: 8),
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
              const SizedBox(height: 32), // Extra space at bottom
            ],
          ),
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
  
  String _getScheduleLabel() {
    switch (_repeatType) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.interval:
        return 'Interval';
      case RepeatType.weekly:
        return 'Daily'; // Weekly is no longer supported, default to Daily
    }
  }
  
  String _getScheduleDescription() {
    switch (_repeatType) {
      case RepeatType.daily:
        if (_selectedDaysOfWeek.isEmpty) {
          return 'Every day';
        } else {
          final days = _selectedDaysOfWeek.map((d) => _getDayName(d)).join(', ');
          return 'Days: $days';
        }
      case RepeatType.monthly:
        if (_monthlyDay == -1) {
          return 'Last day of month';
        } else {
          return '${_monthlyDay}${_getDaySuffix(_monthlyDay)} of month';
        }
      case RepeatType.weekly:
        // Weekly is no longer supported, default to daily
        return 'Every day';
      case RepeatType.interval:
        return 'Every $_intervalDays days';
    }
  }
}

