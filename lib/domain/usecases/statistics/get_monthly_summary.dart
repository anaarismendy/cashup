import 'package:cashup/domain/repositories/statistics_repository.dart';
import 'package:cashup/domain/entities/monthly_summary_entity.dart';

/// **GET_MONTHLY_SUMMARY (Caso de Uso: Obtener Resumen Mensual)**
/// 
/// Encapsula la lógica de negocio para obtener resumen mensual.
class GetMonthlySummary {
  final StatisticsRepository _repository;

  GetMonthlySummary(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - year: Año (requerido)
  /// - month: Mes (1-12, requerido)
  /// 
  /// **Retorna:** Resumen mensual o null si no hay datos
  Future<MonthlySummaryEntity?> call({
    required int year,
    required int month,
  }) async {
    return await _repository.getMonthlySummary(
      year: year,
      month: month,
    );
  }
}

