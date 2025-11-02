import 'package:equatable/equatable.dart';

enum GoalStatus {
  active,
  completed,
  archived,
}

class Goal extends Equatable {
  final int? id;
  final String title;
  final String emoji;
  final double current;
  final double target;
  final DateTime targetDate;
  final GoalStatus status;
  final DateTime? completedDate;
  final DateTime createdAt;

  const Goal({
    this.id,
    required this.title,
    required this.emoji,
    required this.current,
    required this.target,
    required this.targetDate,
    required this.status,
    this.completedDate,
    required this.createdAt,
  });

  Goal copyWith({
    int? id,
    String? title,
    String? emoji,
    double? current,
    double? target,
    DateTime? targetDate,
    GoalStatus? status,
    DateTime? completedDate,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      current: current ?? this.current,
      target: target ?? this.target,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'current': current,
      'target': target,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'status': status.name,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int?,
      title: map['title'] as String,
      emoji: map['emoji'] as String,
      current: (map['current'] as num).toDouble(),
      target: (map['target'] as num).toDouble(),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GoalStatus.active,
      ),
      completedDate: map['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  
  double get remaining => (target - current).clamp(0.0, double.infinity);

  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays.clamp(0, 999999);
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
        current,
        target,
        targetDate,
        status,
        completedDate,
        createdAt,
      ];
}

