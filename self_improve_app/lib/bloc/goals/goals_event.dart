import 'package:equatable/equatable.dart';
import '../../models/goal.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object> get props => [];
}

class GoalsInitialized extends GoalsEvent {
  const GoalsInitialized();
}

class GoalsRefreshed extends GoalsEvent {
  const GoalsRefreshed();
}

class GoalAdded extends GoalsEvent {
  final Goal goal;

  const GoalAdded(this.goal);

  @override
  List<Object> get props => [goal];
}

class GoalUpdated extends GoalsEvent {
  final Goal goal;

  const GoalUpdated(this.goal);

  @override
  List<Object> get props => [goal];
}

class GoalDeleted extends GoalsEvent {
  final int goalId;

  const GoalDeleted(this.goalId);

  @override
  List<Object> get props => [goalId];
}

class ContributionAdded extends GoalsEvent {
  final int goalId;
  final double amount;

  const ContributionAdded(this.goalId, this.amount);

  @override
  List<Object> get props => [goalId, amount];
}

class GoalStatusChanged extends GoalsEvent {
  final int goalId;
  final GoalStatus status;

  const GoalStatusChanged(this.goalId, this.status);

  @override
  List<Object> get props => [goalId, status];
}

