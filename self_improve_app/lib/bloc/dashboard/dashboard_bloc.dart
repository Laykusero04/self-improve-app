import 'package:bloc/bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardInitialized>(_onDashboardInitialized);
    on<DashboardRefreshed>(_onDashboardRefreshed);
  }

  Future<void> _onDashboardInitialized(
    DashboardInitialized event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // TODO: Load dashboard data
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const DashboardLoaded());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onDashboardRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // TODO: Refresh dashboard data
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const DashboardLoaded());
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}

