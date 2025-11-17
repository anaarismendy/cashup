import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **STATISTICS_EVENT (Eventos del BLoC de Estadísticas)**
/// 
/// Define todos los eventos que pueden ocurrir en la pantalla de estadísticas.
/// 
/// **Eventos:**
/// - StatisticsDataRequested: Solicita cargar los datos iniciales
/// - StatisticsPeriodChanged: Cambia el período de visualización (Semana, Mes, Año, Personalizado)
/// - StatisticsTypeChanged: Cambia el tipo de transacción (ingresos o gastos)
/// - StatisticsDateRangeChanged: Cambia el rango de fechas personalizado
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Solicitar datos iniciales
class StatisticsDataRequested extends StatisticsEvent {
  const StatisticsDataRequested();
}

/// Evento: Cambiar período de visualización
class StatisticsPeriodChanged extends StatisticsEvent {
  final StatisticsPeriod period;

  const StatisticsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

/// Evento: Cambiar tipo de transacción
class StatisticsTypeChanged extends StatisticsEvent {
  final TransactionType? type;

  const StatisticsTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Evento: Seleccionar fecha específica (día, semana, mes o año)
class StatisticsDateSelected extends StatisticsEvent {
  final StatisticsPeriod period;
  final DateTime selectedDate;

  const StatisticsDateSelected({
    required this.period,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [period, selectedDate];
}

/// Evento: Cambiar filtro de mostrar solo gastos diarios
class StatisticsShowDailyOnlyChanged extends StatisticsEvent {
  final bool showDailyOnly;

  const StatisticsShowDailyOnlyChanged(this.showDailyOnly);

  @override
  List<Object?> get props => [showDailyOnly];
}

/// Enum para los períodos disponibles
enum StatisticsPeriod {
  day,       // Día específico
  week,      // Semana específica
  month,     // Mes específico
  year,      // Año específico
}

