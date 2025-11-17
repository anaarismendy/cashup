import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/category_statistics_entity.dart';
import 'package:cashup/domain/entities/daily_summary_entity.dart';
import 'package:cashup/domain/entities/weekly_summary_entity.dart';
import 'package:cashup/domain/entities/monthly_summary_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_event.dart';

/// **STATISTICS_STATE (Estados del BLoC de Estadísticas)**
/// 
/// Define todos los estados posibles de la pantalla de estadísticas.
abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial (antes de cargar datos)
class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

/// Estado: Cargando datos
class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

/// Estado: Datos cargados exitosamente
class StatisticsLoaded extends StatisticsState {
  /// Estadísticas por categoría
  final List<CategoryStatisticsEntity> categoryStatistics;
  
  /// Resumen semanal (si está disponible)
  final WeeklySummaryEntity? weeklySummary;
  
  /// Resumen mensual (si está disponible)
  final MonthlySummaryEntity? monthlySummary;
  
  /// Resúmenes diarios (si están disponibles)
  final List<DailySummaryEntity> dailySummaries;
  
  /// Período actual seleccionado
  final StatisticsPeriod period;
  
  /// Fecha seleccionada para el período
  final DateTime selectedDate;
  
  /// Tipo de transacción filtrado (null = todos)
  final TransactionType? type;
  
  /// Fecha de inicio calculada según el período
  final DateTime startDate;
  
  /// Fecha de fin calculada según el período
  final DateTime endDate;
  
  /// Mostrar solo gastos diarios
  final bool showDailyOnly;
  
  /// Total de ingresos
  final double totalIncome;
  
  /// Total de gastos
  final double totalExpenses;
  
  /// Balance total
  final double balance;

  const StatisticsLoaded({
    required this.categoryStatistics,
    this.weeklySummary,
    this.monthlySummary,
    this.dailySummaries = const [],
    required this.period,
    required this.selectedDate,
    this.type,
    required this.startDate,
    required this.endDate,
    this.showDailyOnly = false,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
  });

  @override
  List<Object?> get props => [
        categoryStatistics,
        weeklySummary,
        monthlySummary,
        dailySummaries,
        period,
        selectedDate,
        type,
        startDate,
        endDate,
        showDailyOnly,
        totalIncome,
        totalExpenses,
        balance,
      ];

  StatisticsLoaded copyWith({
    List<CategoryStatisticsEntity>? categoryStatistics,
    WeeklySummaryEntity? weeklySummary,
    MonthlySummaryEntity? monthlySummary,
    List<DailySummaryEntity>? dailySummaries,
    StatisticsPeriod? period,
    DateTime? selectedDate,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? showDailyOnly,
    double? totalIncome,
    double? totalExpenses,
    double? balance,
  }) {
    return StatisticsLoaded(
      categoryStatistics: categoryStatistics ?? this.categoryStatistics,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      dailySummaries: dailySummaries ?? this.dailySummaries,
      period: period ?? this.period,
      selectedDate: selectedDate ?? this.selectedDate,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      showDailyOnly: showDailyOnly ?? this.showDailyOnly,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      balance: balance ?? this.balance,
    );
  }
}

/// Estado: Error al cargar datos
class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

