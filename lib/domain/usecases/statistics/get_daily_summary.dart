import 'package:cashup/domain/repositories/statistics_repository.dart';
import 'package:cashup/domain/entities/daily_summary_entity.dart';

/// **GET_DAILY_SUMMARY (Caso de Uso: Obtener Resumen Diario)**
/// 
/// Encapsula la lógica de negocio para obtener resúmenes diarios.
class GetDailySummary {
  final StatisticsRepository _repository;

  GetDailySummary(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio (opcional)
  /// - endDate: Fecha de fin (opcional)
  /// 
  /// **Retorna:** Lista de resúmenes diarios
  Future<List<DailySummaryEntity>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getDailySummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

