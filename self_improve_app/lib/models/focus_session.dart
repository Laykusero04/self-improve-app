import 'package:equatable/equatable.dart';

class FocusSession extends Equatable {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in seconds
  final String category;
  final String date; // Format: "YYYY-MM-DD" for easy grouping
  final DateTime createdAt;

  const FocusSession({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  FocusSession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? category,
    String? date,
    DateTime? createdAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'duration': duration,
      'category': category,
      'date': date,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as int?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      duration: map['duration'] as int,
      category: map['category'] as String,
      date: map['date'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  List<Object?> get props => [id, startTime, endTime, duration, category, date, createdAt];
}

