import 'package:cashup/domain/repositories/statistics_repository.dart';
import 'package:cashup/domain/entities/category_statistics_entity.dart';
import 'package:cashup/domain/entities/daily_summary_entity.dart';
import 'package:cashup/domain/entities/monthly_summary_entity.dart';
import 'package:cashup/domain/entities/weekly_summary_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/data/datasources/supabase_statistics_datasource.dart';

/// **STATISTICS_REPOSITORY_IMPL (Implementación del Repositorio de Estadísticas)**
/// 
/// Implementación concreta del repositorio que utiliza SupabaseStatisticsDataSource.
/// 
/// **Responsabilidades:**
/// - Convierte modelos de datos a entidades de dominio
/// - Maneja errores y los convierte a excepciones de dominio
/// - Actúa como puente entre la capa de datos y la capa de dominio
class StatisticsRepositoryImpl implements StatisticsRepository {
  final SupabaseStatisticsDataSource _dataSource;

  StatisticsRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryStatisticsEntity>> getCategoryStatistics({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      final models = await _dataSource.getCategoryStatistics(
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
      // Los modelos extienden las entidades, así que podemos retornarlos directamente
      return models;
    } catch (e) {
      throw Exception('Error al obtener estadísticas de categorías: $e');
    }
  }

  @override
  Future<List<DailySummaryEntity>> getDailySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _dataSource.getDailySummary(
        startDate: startDate,
        endDate: endDate,
      );
      // Los modelos extienden las entidades, así que podemos retornarlos directamente
      return models;
    } catch (e) {
      throw Exception('Error al obtener resumen diario: $e');
    }
  }

  @override
  Future<WeeklySummaryEntity?> getWeeklySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = await _dataSource.getWeeklySummary(
        startDate: startDate,
        endDate: endDate,
      );
      return model;
    } catch (e) {
      throw Exception('Error al obtener resumen semanal: $e');
    }
  }

  @override
  Future<MonthlySummaryEntity?> getMonthlySummary({
    required int year,
    required int month,
  }) async {
    try {
      final model = await _dataSource.getMonthlySummary(
        year: year,
        month: month,
      );
      return model;
    } catch (e) {
      throw Exception('Error al obtener resumen mensual: $e');
    }
  }
}

