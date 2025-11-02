import 'package:bloc/bloc.dart';
import 'goals_event.dart';
import 'goals_state.dart';
import '../../services/database_service.dart';
import '../../models/goal.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final DatabaseService _databaseService = DatabaseService.instance;

  GoalsBloc() : super(const GoalsState()) {
    on<GoalsInitialized>(_onGoalsInitialized);
    on<GoalsRefreshed>(_onGoalsRefreshed);
    on<GoalAdded>(_onGoalAdded);
    on<GoalUpdated>(_onGoalUpdated);
    on<GoalDeleted>(_onGoalDeleted);
    on<ContributionAdded>(_onContributionAdded);
    on<GoalStatusChanged>(_onGoalStatusChanged);
  }

  Future<void> _onGoalsInitialized(
    GoalsInitialized event,
    Emitter<GoalsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    await _loadGoals(emit);
  }

  Future<void> _onGoalsRefreshed(
    GoalsRefreshed event,
    Emitter<GoalsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    await _loadGoals(emit);
  }

  Future<void> _loadGoals(Emitter<GoalsState> emit) async {
    try {
      final allGoals = await _databaseService.getGoals();
      
      final activeGoals = allGoals.where((g) => g.status == GoalStatus.active).toList();
      final completedGoals = allGoals.where((g) => g.status == GoalStatus.completed).toList();
      final archivedGoals = allGoals.where((g) => g.status == GoalStatus.archived).toList();

      emit(state.copyWith(
        allGoals: allGoals,
        activeGoals: activeGoals,
        completedGoals: completedGoals,
        archivedGoals: archivedGoals,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onGoalAdded(
    GoalAdded event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      await _databaseService.insertGoal(event.goal);
      add(const GoalsRefreshed());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onGoalUpdated(
    GoalUpdated event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      await _databaseService.updateGoal(event.goal);
      add(const GoalsRefreshed());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onGoalDeleted(
    GoalDeleted event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      await _databaseService.deleteGoal(event.goalId);
      add(const GoalsRefreshed());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onContributionAdded(
    ContributionAdded event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      // Get goal before adding contribution to check if it will be completed
      final originalGoal = await _databaseService.getGoal(event.goalId);
      if (originalGoal == null) return;

      await _databaseService.addContribution(event.goalId, event.amount);

      // Check if goal was completed
      final updatedGoal = await _databaseService.getGoal(event.goalId);
      if (updatedGoal != null && updatedGoal.status == GoalStatus.completed && originalGoal.status == GoalStatus.active) {
        emit(state.copyWith(recentlyCompletedGoalTitle: updatedGoal.title));
      }
      
      add(const GoalsRefreshed());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onGoalStatusChanged(
    GoalStatusChanged event,
    Emitter<GoalsState> emit,
  ) async {
    try {
      final goal = await _databaseService.getGoal(event.goalId);
      if (goal != null) {
        // Check if goal is being marked as completed
        final wasActive = goal.status == GoalStatus.active;
        final willBeCompleted = event.status == GoalStatus.completed;
        
        final updatedGoal = goal.copyWith(
          status: event.status,
          completedDate: event.status == GoalStatus.completed ? DateTime.now() : null,
        );
        await _databaseService.updateGoal(updatedGoal);
        
        // Show completion message if marking as done from active status
        if (wasActive && willBeCompleted) {
          emit(state.copyWith(recentlyCompletedGoalTitle: updatedGoal.title));
        }
        
        add(const GoalsRefreshed());
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

