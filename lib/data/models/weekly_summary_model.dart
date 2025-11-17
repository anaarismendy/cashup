import 'package:cashup/domain/entities/weekly_summary_entity.dart';

/// **WEEKLY_SUMMARY_MODEL (Modelo de Resumen Semanal)**
/// 
/// Modelo de datos que convierte los datos de Supabase a la entidad de dominio.
class WeeklySummaryModel extends WeeklySummaryEntity {
  const WeeklySummaryModel({
    required super.weekStart,
    required super.weekEnd,
    required super.totalIncome,
    required super.totalExpense,
    required super.balance,
    required super.transactionCount,
  });

  /// Convierte un Map de Supabase a WeeklySummaryModel
  /// 
  /// **Parámetros esperados de Supabase:**
  /// - week_start: Fecha de inicio de la semana (DATE)
  /// - week_end: Fecha de fin de la semana (DATE)
  /// - total_income: Total de ingresos de la semana (NUMERIC)
  /// - total_expense: Total de gastos de la semana (NUMERIC)
  /// - balance: Balance de la semana (NUMERIC)
  /// - transaction_count: Número de transacciones (BIGINT)
  factory WeeklySummaryModel.fromJson(Map<String, dynamic> json) {
    return WeeklySummaryModel(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }

  /// Convierte WeeklySummaryModel a Map
  Map<String, dynamic> toJson() {
    return {
      'week_start': weekStart.toIso8601String().split('T')[0],
      'week_end': weekEnd.toIso8601String().split('T')[0],
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'balance': balance,
      'transaction_count': transactionCount,
    };
  }
}

