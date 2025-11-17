import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashup/data/models/category_statistics_model.dart';
import 'package:cashup/data/models/daily_summary_model.dart';
import 'package:cashup/data/models/monthly_summary_model.dart';
import 'package:cashup/data/models/weekly_summary_model.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **SUPABASE_STATISTICS_DATASOURCE (Fuente de Datos de Estadísticas)**
/// 
/// Maneja todas las interacciones con las funciones RPC de Supabase para estadísticas.
/// 
/// **Funciones RPC utilizadas:**
/// - get_category_statistics: Obtiene estadísticas por categoría
/// - get_daily_summary: Obtiene resúmenes diarios
/// - get_monthly_summary: Obtiene resúmenes mensuales
class SupabaseStatisticsDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseStatisticsDataSource(this._supabaseClient);

  /// Obtiene estadísticas de categorías
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio (opcional)
  /// - endDate: Fecha de fin (opcional)
  /// - type: Tipo de transacción (opcional, 'income' o 'expense')
  /// 
  /// **Retorna:** Lista de estadísticas por categoría
  Future<List<CategoryStatisticsModel>> getCategoryStatistics({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear los parámetros para la llamada RPC
      final params = <String, dynamic>{
        'p_user_id': userId,
      };

      if (startDate != null) {
        // Convertir la fecha a formato ISO 8601 y obtener solo la parte de la fecha
        params['p_start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        // Convertir la fecha a formato ISO 8601 y obtener solo la parte de la fecha
        params['p_end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (type != null) {
        // Convertir el tipo de transacción a JSON
        params['p_type'] = type.toJson();
      }

      final response = await _supabaseClient.rpc(
        'get_category_statistics',
        params: params,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      // Filtrar y mapear solo los elementos válidos
      final List<CategoryStatisticsModel> results = [];
      for (final item in response) {
        try {
          if (item is Map<String, dynamic>) {
            // Solo incluir categorías que tengan transacciones (transaction_count > 0)
            final transactionCount = item['transaction_count'] as int? ?? 0;
            if (transactionCount > 0) {
              // Agregar la categoría a la lista de resultados
              results.add(CategoryStatisticsModel.fromJson(item));
            }
          }
        } catch (e) {
          // Log del error pero continuar con las demás categorías
          throw Exception('Error al procesar categoría: $e');
        }
      }

      return results;
    } on PostgrestException catch (e) {
      throw Exception('Error de Supabase al obtener estadísticas: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener estadísticas de categorías: $e');
    }
  }

  /// Obtiene resúmenes diarios
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio (opcional)
  /// - endDate: Fecha de fin (opcional)
  /// 
  /// **Retorna:** Lista de resúmenes diarios
  Future<List<DailySummaryModel>> getDailySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final params = <String, dynamic>{
        'p_user_id': userId,
      };

      if (startDate != null) {
        params['p_start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        params['p_end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _supabaseClient.rpc(
        'get_daily_summary',
        params: params,
      );

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((json) => DailySummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener resumen diario: $e');
    }
  }

  /// Obtiene resumen semanal
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio de la semana (opcional)
  /// - endDate: Fecha de fin de la semana (opcional)
  /// 
  /// **Retorna:** Resumen semanal o null si no hay datos
  Future<WeeklySummaryModel?> getWeeklySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final params = <String, dynamic>{
        'p_user_id': userId,
      };

      if (startDate != null) {
        params['p_start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        params['p_end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _supabaseClient.rpc(
        'get_weekly_summary',
        params: params,
      );

      if (response == null || response.isEmpty) {
        return null;
      }

      return WeeklySummaryModel.fromJson(
        response.first as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Error al obtener resumen semanal: $e');
    }
  }

  /// Obtiene resumen mensual
  /// 
  /// **Parámetros:**
  /// - year: Año (requerido)
  /// - month: Mes (1-12, requerido)
  /// 
  /// **Retorna:** Resumen mensual o null si no hay datos
  Future<MonthlySummaryModel?> getMonthlySummary({
    required int year,
    required int month,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabaseClient.rpc(
        'get_monthly_summary',
        params: {
          'p_user_id': userId,
          'p_year': year,
          'p_month': month,
        },
      );

      if (response == null || response.isEmpty) {
        return null;
      }

      return MonthlySummaryModel.fromJson(
        response.first as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Error al obtener resumen mensual: $e');
    }
  }
}

