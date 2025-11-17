import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/domain/usecases/statistics/get_category_statistics.dart';
import 'package:cashup/domain/usecases/statistics/get_daily_summary.dart';
import 'package:cashup/domain/usecases/statistics/get_weekly_summary.dart';
import 'package:cashup/domain/usecases/statistics/get_monthly_summary.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/entities/weekly_summary_entity.dart';
import 'package:cashup/domain/entities/monthly_summary_entity.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_event.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_state.dart';

/// **STATISTICS_BLOC (BLoC de Estadísticas)**
/// 
/// Gestiona el estado y la lógica de negocio de la pantalla de estadísticas.
/// 
/// **Responsabilidades:**
/// - Cargar estadísticas de categorías
/// - Cargar resúmenes diarios, semanales y mensuales
/// - Manejar cambios de período y filtros
/// - Calcular totales (ingresos, gastos, balance)
/// - Manejar selección de fechas específicas
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetCategoryStatistics _getCategoryStatistics;
  final GetDailySummary _getDailySummary;
  final GetWeeklySummary _getWeeklySummary;
  final GetMonthlySummary _getMonthlySummary;

  StatisticsBloc({
    required GetCategoryStatistics getCategoryStatistics,
    required GetDailySummary getDailySummary,
    required GetWeeklySummary getWeeklySummary,
    required GetMonthlySummary getMonthlySummary,
  })  : _getCategoryStatistics = getCategoryStatistics,
        _getDailySummary = getDailySummary,
        _getWeeklySummary = getWeeklySummary,
        _getMonthlySummary = getMonthlySummary,
        super(const StatisticsInitial()) {
    // Registrar manejadores de eventos
    on<StatisticsDataRequested>(_onDataRequested);
    on<StatisticsPeriodChanged>(_onPeriodChanged);
    on<StatisticsTypeChanged>(_onTypeChanged);
    on<StatisticsDateSelected>(_onDateSelected);
    on<StatisticsShowDailyOnlyChanged>(_onShowDailyOnlyChanged);
  }

  /// Maneja la solicitud inicial de datos
  Future<void> _onDataRequested(
    StatisticsDataRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      // Por defecto, mostrar el mes actual
      final now = DateTime.now();
      final selectedDate = DateTime(now.year, now.month, 1);
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      await _loadStatistics(
        emit: emit,
        period: StatisticsPeriod.month,
        selectedDate: selectedDate,
        startDate: startDate,
        endDate: endDate,
        type: null,
        showDailyOnly: false,
      );
    } catch (e) {
      emit(StatisticsError('Error al cargar estadísticas: $e'));
    }
  }

  /// Maneja el cambio de período (sin cambiar la fecha seleccionada)
  Future<void> _onPeriodChanged(
    StatisticsPeriodChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StatisticsLoaded) return;

    emit(const StatisticsLoading());

    try {
      // Calcular fechas según el período y la fecha seleccionada actual
      final dateRange = _calculateDateRange(
        period: event.period,
        selectedDate: currentState.selectedDate,
      );

      await _loadStatistics(
        emit: emit,
        period: event.period,
        selectedDate: currentState.selectedDate,
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
        type: currentState.type,
        showDailyOnly: currentState.showDailyOnly,
      );
    } catch (e) {
      emit(StatisticsError('Error al cambiar período: $e'));
    }
  }

  /// Maneja la selección de una fecha específica
  Future<void> _onDateSelected(
    StatisticsDateSelected event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      // Calcular fechas según el período y la fecha seleccionada
      final dateRange = _calculateDateRange(
        period: event.period,
        selectedDate: event.selectedDate,
      );

      await _loadStatistics(
        emit: emit,
        period: event.period,
        selectedDate: event.selectedDate,
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
        type: null,
        showDailyOnly: false,
      );
    } catch (e) {
      emit(StatisticsError('Error al seleccionar fecha: $e'));
    }
  }

  /// Maneja el cambio de tipo de transacción
  Future<void> _onTypeChanged(
    StatisticsTypeChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StatisticsLoaded) return;

    emit(const StatisticsLoading());

    try {
      await _loadStatistics(
        emit: emit,
        period: currentState.period,
        selectedDate: currentState.selectedDate,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        type: event.type,
        showDailyOnly: currentState.showDailyOnly,
      );
    } catch (e) {
      emit(StatisticsError('Error al cambiar tipo: $e'));
    }
  }

  /// Maneja el cambio del toggle de mostrar solo gastos diarios
  Future<void> _onShowDailyOnlyChanged(
    StatisticsShowDailyOnlyChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StatisticsLoaded) return;

    // Solo actualizar el estado sin recargar datos
    emit(currentState.copyWith(showDailyOnly: event.showDailyOnly));
  }

  /// Calcula el rango de fechas según el período y la fecha seleccionada
  Map<String, DateTime> _calculateDateRange({
    required StatisticsPeriod period,
    required DateTime selectedDate,
  }) {
    DateTime startDate;
    DateTime endDate;

    switch (period) {
      case StatisticsPeriod.day:
        // Día específico
        startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        endDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
        break;
      case StatisticsPeriod.week:
        // Semana específica (lunes a domingo)
        final weekday = selectedDate.weekday; // 1 = lunes, 7 = domingo
        startDate = selectedDate.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 6));
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        break;
      case StatisticsPeriod.month:
        // Mes específico
        startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);
        break;
      case StatisticsPeriod.year:
        // Año específico
        startDate = DateTime(selectedDate.year, 1, 1);
        endDate = DateTime(selectedDate.year, 12, 31, 23, 59, 59);
        break;
    }

    return {'start': startDate, 'end': endDate};
  }

  /// Carga las estadísticas según los parámetros dados
  Future<void> _loadStatistics({
    required Emitter<StatisticsState> emit,
    required StatisticsPeriod period,
    required DateTime selectedDate,
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? type,
    required bool showDailyOnly,
  }) async {
    try {
      // Cargar estadísticas de categorías (solo gastos si showDailyOnly es true)
      final categoryStats = await _getCategoryStatistics(
        startDate: startDate,
        endDate: endDate,
        type: showDailyOnly ? TransactionType.expense : type,
      );

      // Cargar resumen semanal si el período es semanal
      WeeklySummaryEntity? weeklySummary;
      if (period == StatisticsPeriod.week) {
        weeklySummary = await _getWeeklySummary(
          startDate: startDate,
          endDate: endDate,
        );
      }

      // Cargar resumen mensual si el período es mensual
      MonthlySummaryEntity? monthlySummary;
      if (period == StatisticsPeriod.month) {
        monthlySummary = await _getMonthlySummary(
          year: startDate.year,
          month: startDate.month,
        );
      }

      // Cargar resúmenes diarios
      final dailySummaries = await _getDailySummary(
        startDate: startDate,
        endDate: endDate,
      );

      // Calcular totales
      double totalIncome = 0.0;
      double totalExpenses = 0.0;

      if (type == null || type == TransactionType.income) {
        totalIncome = categoryStats
            .where((stat) => stat.categoryType == TransactionType.income)
            .fold(0.0, (sum, stat) => sum + stat.totalAmount);
      }

      if (type == null || type == TransactionType.expense) {
        totalExpenses = categoryStats
            .where((stat) => stat.categoryType == TransactionType.expense)
            .fold(0.0, (sum, stat) => sum + stat.totalAmount);
      }

      final balance = totalIncome - totalExpenses;

      emit(StatisticsLoaded(
        categoryStatistics: categoryStats,
        weeklySummary: weeklySummary,
        monthlySummary: monthlySummary,
        dailySummaries: dailySummaries,
        period: period,
        selectedDate: selectedDate,
        type: type,
        startDate: startDate,
        endDate: endDate,
        showDailyOnly: showDailyOnly,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
      ));
    } catch (e) {
      emit(StatisticsError('Error al cargar estadísticas: $e'));
    }
  }
}
