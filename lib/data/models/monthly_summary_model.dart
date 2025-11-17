import 'package:cashup/domain/entities/monthly_summary_entity.dart';

/// **MONTHLY_SUMMARY_MODEL (Modelo de Resumen Mensual)**
/// 
/// Modelo de datos que convierte los datos de Supabase a la entidad de dominio.
class MonthlySummaryModel extends MonthlySummaryEntity {
  const MonthlySummaryModel({
    required super.monthYear,
    required super.totalIncome,
    required super.totalExpense,
    required super.balance,
    required super.transactionCount,
  });

  /// Convierte un Map de Supabase a MonthlySummaryModel
  /// 
  /// **Parámetros esperados de Supabase:**
  /// - month_year: Año y mes en formato 'YYYY-MM'
  /// - total_income: Total de ingresos del mes (NUMERIC)
  /// - total_expense: Total de gastos del mes (NUMERIC)
  /// - balance: Balance del mes (NUMERIC)
  /// - transaction_count: Número de transacciones (BIGINT)
  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      monthYear: json['month_year'] as String,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
    );
  }

  /// Convierte MonthlySummaryModel a Map
  Map<String, dynamic> toJson() {
    return {
      'month_year': monthYear,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'balance': balance,
      'transaction_count': transactionCount,
    };
  }
}

