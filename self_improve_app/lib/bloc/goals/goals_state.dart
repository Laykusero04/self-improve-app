import 'package:equatable/equatable.dart';
import '../../models/goal.dart';

class GoalsState extends Equatable {
  final List<Goal> allGoals;
  final List<Goal> activeGoals;
  final List<Goal> completedGoals;
  final List<Goal> archivedGoals;
  final bool isLoading;
  final String? error;
  final String? recentlyCompletedGoalTitle;
  final int? recentlyCompletedGoalId;

  const GoalsState({
    this.allGoals = const [],
    this.activeGoals = const [],
    this.completedGoals = const [],
    this.archivedGoals = const [],
    this.isLoading = false,
    this.error,
    this.recentlyCompletedGoalTitle,
    this.recentlyCompletedGoalId,
  });

  GoalsState copyWith({
    List<Goal>? allGoals,
    List<Goal>? activeGoals,
    List<Goal>? completedGoals,
    List<Goal>? archivedGoals,
    bool? isLoading,
    String? error,
    String? recentlyCompletedGoalTitle,
    int? recentlyCompletedGoalId,
  }) {
    return GoalsState(
      allGoals: allGoals ?? this.allGoals,
      activeGoals: activeGoals ?? this.activeGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      archivedGoals: archivedGoals ?? this.archivedGoals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recentlyCompletedGoalTitle: recentlyCompletedGoalTitle,
      recentlyCompletedGoalId: recentlyCompletedGoalId,
    );
  }

  @override
  List<Object?> get props => [
        allGoals,
        activeGoals,
        completedGoals,
        archivedGoals,
        isLoading,
        error,
        recentlyCompletedGoalTitle,
        recentlyCompletedGoalId,
      ];
}

