import 'package:cashup/domain/entities/daily_summary_entity.dart';

/// **DAILY_SUMMARY_MODEL (Modelo de Resumen Diario)**
/// 
/// Modelo de datos que convierte los datos de Supabase a la entidad de dominio.
class DailySummaryModel extends DailySummaryEntity {
  const DailySummaryModel({
    required super.userId,
    required super.transactionDate,
    required super.dailyIncome,
    required super.dailyExpense,
    required super.dailyBalance,
    required super.transactionCount,
  });

  /// Convierte un Map de Supabase a DailySummaryModel
  /// 
  /// **Parámetros esperados de Supabase:**
  /// - user_id: UUID del usuario
  /// - transaction_date: Fecha de la transacción (DATE)
  /// - daily_income: Total de ingresos del día (NUMERIC)
  /// - daily_expense: Total de gastos del día (NUMERIC)
  /// - daily_balance: Balance del día (NUMERIC)
  /// - transaction_count: Número de transacciones (BIGINT)
  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryModel(
      userId: json['user_id'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      dailyIncome: (json['daily_income'] as num?)?.toDouble() ?? 0.0,
      dailyExpense: (json['daily_expense'] as num?)?.toDouble() ?? 0.0,
      dailyBalance: (json['daily_balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }

  /// Convierte DailySummaryModel a Map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'daily_income': dailyIncome,
      'daily_expense': dailyExpense,
      'daily_balance': dailyBalance,
      'transaction_count': transactionCount,
    };
  }
}

