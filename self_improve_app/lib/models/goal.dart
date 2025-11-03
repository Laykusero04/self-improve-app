import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GoalStatus {
  active,
  completed,
  archived,
}

enum GoalType {
  habit,
  saving,
}

enum RepeatType {
  daily,
  weekly,
  monthly,
  interval,
}

enum EndConditionType {
  never,
  onDate,
  afterStreaks,
  afterCompletions,
  byTotalAmount,
}

enum ShowOnPeriod {
  morning,
  afternoon,
  evening,
}

class Goal extends Equatable {
  final int? id;
  final String title;
  final String? emoji; // Optional for backward compatibility
  final GoalType type;
  final Color color;
  final double current;
  final double target;
  final DateTime startDate;
  final DateTime? targetDate;
  final GoalStatus status;
  final DateTime? completedDate;
  final DateTime createdAt;
  
  // Schedule options
  final RepeatType repeatType;
  final Set<int> selectedDaysOfWeek; // 0 = Sunday, 6 = Saturday
  final int intervalDays; // For interval repeat type
  final int timesPerDay;
  
  // Reminder options
  final TimeOfDay? reminderTime;
  final Set<ShowOnPeriod> showOnPeriods;
  
  // Checklist
  final List<String> checklistItems;
  
  // End conditions
  final EndConditionType endConditionType;
  final int? endConditionValue; // For streaks, completions, or amount

  Goal({
    this.id,
    required this.title,
    this.emoji,
    this.type = GoalType.saving,
    Color? color,
    required this.current,
    required this.target,
    DateTime? startDate,
    this.targetDate,
    required this.status,
    this.completedDate,
    required this.createdAt,
    this.repeatType = RepeatType.daily,
    this.selectedDaysOfWeek = const {},
    this.intervalDays = 1,
    this.timesPerDay = 1,
    this.reminderTime,
    this.showOnPeriods = const {ShowOnPeriod.morning, ShowOnPeriod.afternoon, ShowOnPeriod.evening},
    this.checklistItems = const [],
    this.endConditionType = EndConditionType.never,
    this.endConditionValue,
  }) : color = color ?? const Color(0xFF2196F3),
       startDate = startDate ?? DateTime.now();

  Goal copyWith({
    int? id,
    String? title,
    String? emoji,
    GoalType? type,
    Color? color,
    double? current,
    double? target,
    DateTime? startDate,
    DateTime? targetDate,
    GoalStatus? status,
    DateTime? completedDate,
    DateTime? createdAt,
    RepeatType? repeatType,
    Set<int>? selectedDaysOfWeek,
    int? intervalDays,
    int? timesPerDay,
    TimeOfDay? reminderTime,
    Set<ShowOnPeriod>? showOnPeriods,
    List<String>? checklistItems,
    EndConditionType? endConditionType,
    int? endConditionValue,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      color: color ?? this.color,
      current: current ?? this.current,
      target: target ?? this.target,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      repeatType: repeatType ?? this.repeatType,
      selectedDaysOfWeek: selectedDaysOfWeek ?? this.selectedDaysOfWeek,
      intervalDays: intervalDays ?? this.intervalDays,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      reminderTime: reminderTime ?? this.reminderTime,
      showOnPeriods: showOnPeriods ?? this.showOnPeriods,
      checklistItems: checklistItems ?? this.checklistItems,
      endConditionType: endConditionType ?? this.endConditionType,
      endConditionValue: endConditionValue ?? this.endConditionValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji ?? '',
      'type': type.name,
      'colorValue': color.value,
      'current': current,
      'target': target,
      'startDate': startDate.millisecondsSinceEpoch,
      'targetDate': targetDate?.millisecondsSinceEpoch,
      'status': status.name,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'repeatType': repeatType.name,
      'selectedDaysOfWeek': selectedDaysOfWeek.join(','),
      'intervalDays': intervalDays,
      'timesPerDay': timesPerDay,
      'reminderTime': reminderTime != null ? '${reminderTime!.hour}:${reminderTime!.minute}' : null,
      'showOnPeriods': showOnPeriods.map((p) => p.name).join(','),
      'checklistItems': checklistItems.join('|'),
      'endConditionType': endConditionType.name,
      'endConditionValue': endConditionValue,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    // Parse selected days of week
    Set<int> selectedDays = {};
    if (map['selectedDaysOfWeek'] != null && map['selectedDaysOfWeek'].toString().isNotEmpty) {
      selectedDays = map['selectedDaysOfWeek']
          .toString()
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? -1)
          .where((i) => i >= 0 && i <= 6)
          .toSet();
    }
    
    // Parse reminder time
    TimeOfDay? reminderTime;
    if (map['reminderTime'] != null && map['reminderTime'].toString().isNotEmpty) {
      final parts = map['reminderTime'].toString().split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          reminderTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
    
    // Parse show on periods
    Set<ShowOnPeriod> showOnPeriods = {
      ShowOnPeriod.morning,
      ShowOnPeriod.afternoon,
      ShowOnPeriod.evening,
    };
    if (map['showOnPeriods'] != null && map['showOnPeriods'].toString().isNotEmpty) {
      showOnPeriods = map['showOnPeriods']
          .toString()
          .split(',')
          .map((s) => ShowOnPeriod.values.firstWhere(
                (e) => e.name == s,
                orElse: () => ShowOnPeriod.morning,
              ))
          .toSet();
    }
    
    // Parse checklist items
    List<String> checklistItems = [];
    if (map['checklistItems'] != null && map['checklistItems'].toString().isNotEmpty) {
      checklistItems = map['checklistItems'].toString().split('|').where((s) => s.isNotEmpty).toList();
    }
    
    // Parse dates with fallback for old data
    DateTime? targetDate;
    if (map['targetDate'] != null) {
      try {
        targetDate = DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int);
      } catch (e) {
        // Invalid date, ignore
      }
    }
    
    // If end condition is onDate and targetDate is null, use endConditionValue
    if (targetDate == null && map['endConditionType'] != null) {
      final endTypeStr = map['endConditionType'].toString();
      if (endTypeStr == EndConditionType.onDate.name && map['endConditionValue'] != null) {
        try {
          targetDate = DateTime.fromMillisecondsSinceEpoch(map['endConditionValue'] as int);
        } catch (e) {
          // Invalid date, ignore
        }
      }
    }
    
    DateTime startDate = DateTime.now();
    if (map['startDate'] != null) {
      try {
        startDate = DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int);
      } catch (e) {
        // Invalid date, use current date
      }
    } else {
      // Fallback: if no startDate, use createdAt
      if (map['createdAt'] != null) {
        try {
          startDate = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);
        } catch (e) {
          // Use current date
        }
      }
    }
    
    return Goal(
      id: map['id'] as int?,
      title: map['title'] as String,
      emoji: map['emoji'] != null && (map['emoji'] as String).isNotEmpty ? map['emoji'] as String? : null,
      type: map['type'] != null
          ? GoalType.values.firstWhere(
              (e) => e.name == map['type'],
              orElse: () => GoalType.saving,
            )
          : GoalType.saving,
      color: map['colorValue'] != null
          ? Color(map['colorValue'] as int)
          : const Color(0xFF2196F3),
      current: (map['current'] as num).toDouble(),
      target: (map['target'] as num).toDouble(),
      startDate: startDate,
      targetDate: targetDate,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GoalStatus.active,
      ),
      completedDate: map['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      repeatType: map['repeatType'] != null
          ? RepeatType.values.firstWhere(
              (e) => e.name == map['repeatType'],
              orElse: () => RepeatType.daily,
            )
          : RepeatType.daily,
      selectedDaysOfWeek: selectedDays,
      intervalDays: map['intervalDays'] as int? ?? 1,
      timesPerDay: map['timesPerDay'] as int? ?? 1,
      reminderTime: reminderTime,
      showOnPeriods: showOnPeriods,
      checklistItems: checklistItems,
      endConditionType: map['endConditionType'] != null
          ? EndConditionType.values.firstWhere(
              (e) => e.name == map['endConditionType'],
              orElse: () => EndConditionType.never,
            )
          : EndConditionType.never,
      endConditionValue: map['endConditionValue'] as int?,
    );
  }

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  
  double get remaining => (target - current).clamp(0.0, double.infinity);

  int get daysRemaining {
    if (targetDate == null) return 999999;
    final now = DateTime.now();
    return targetDate!.difference(now).inDays.clamp(0, 999999);
  }

  int get suggestedWeekly {
    if (daysRemaining <= 0 || remaining <= 0) return 0;
    final weeksRemaining = (daysRemaining / 7).ceil();
    return (remaining / weeksRemaining).ceil();
  }

  @override
  List<Object?> get props => [
        id,
        title,
        emoji,
        type,
        color,
        current,
        target,
        startDate,
        targetDate,
        status,
        completedDate,
        createdAt,
        repeatType,
        selectedDaysOfWeek,
        intervalDays,
        timesPerDay,
        reminderTime,
        showOnPeriods,
        checklistItems,
        endConditionType,
        endConditionValue,
      ];
}

