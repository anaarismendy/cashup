import 'package:cashup/domain/entities/category_statistics_entity.dart';
import 'package:cashup/domain/entities/daily_summary_entity.dart';
import 'package:cashup/domain/entities/monthly_summary_entity.dart';
import 'package:cashup/domain/entities/weekly_summary_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **STATISTICS_REPOSITORY (Repositorio de Estadísticas)**
/// 
/// Interfaz que define el contrato para obtener estadísticas.
/// Esta es la abstracción de la capa de Dominio que no depende de Supabase.
/// 
/// **Principio de Inversión de Dependencias (SOLID):**
/// - La capa de Dominio define QUÉ necesita (interfaz)
/// - La capa de Datos implementa CÓMO obtenerlo (implementación)
/// - Esto permite cambiar la fuente de datos sin afectar el dominio
abstract class StatisticsRepository {
  /// Obtiene estadísticas de categorías
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio (opcional)
  /// - endDate: Fecha de fin (opcional)
  /// - type: Tipo de transacción (opcional)
  /// 
  /// **Retorna:** Lista de estadísticas por categoría
  Future<List<CategoryStatisticsEntity>> getCategoryStatistics({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  });

  /// Obtiene resúmenes diarios
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio (opcional)
  /// - endDate: Fecha de fin (opcional)
  /// 
  /// **Retorna:** Lista de resúmenes diarios
  Future<List<DailySummaryEntity>> getDailySummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene resumen semanal
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio de la semana (opcional)
  /// - endDate: Fecha de fin de la semana (opcional)
  /// 
  /// **Retorna:** Resumen semanal o null si no hay datos
  Future<WeeklySummaryEntity?> getWeeklySummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene resumen mensual
  /// 
  /// **Parámetros:**
  /// - year: Año (requerido)
  /// - month: Mes (1-12, requerido)
  /// 
  /// **Retorna:** Resumen mensual o null si no hay datos
  Future<MonthlySummaryEntity?> getMonthlySummary({
    required int year,
    required int month,
  });
}

