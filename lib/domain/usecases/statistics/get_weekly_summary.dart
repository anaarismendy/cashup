import 'package:cashup/domain/repositories/statistics_repository.dart';
import 'package:cashup/domain/entities/weekly_summary_entity.dart';

/// **GET_WEEKLY_SUMMARY (Caso de Uso: Obtener Resumen Semanal)**
/// 
/// Encapsula la lógica de negocio para obtener resumen semanal.
class GetWeeklySummary {
  final StatisticsRepository _repository;

  GetWeeklySummary(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio de la semana (opcional)
  /// - endDate: Fecha de fin de la semana (opcional)
  /// 
  /// **Retorna:** Resumen semanal o null si no hay datos
  Future<WeeklySummaryEntity?> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getWeeklySummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

