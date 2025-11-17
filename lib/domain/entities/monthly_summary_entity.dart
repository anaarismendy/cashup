import 'package:equatable/equatable.dart';

/// **MONTHLY_SUMMARY_ENTITY (Entidad de Resumen Mensual)**
/// 
/// Representa un resumen de transacciones para un mes específico.
/// Incluye ingresos totales, gastos totales, balance y número de transacciones.
class MonthlySummaryEntity extends Equatable {
  /// Año y mes en formato 'YYYY-MM'
  final String monthYear;
  
  /// Total de ingresos del mes
  final double totalIncome;
  
  /// Total de gastos del mes
  final double totalExpense;
  
  /// Balance del mes (ingresos - gastos)
  final double balance;
  
  /// Número de transacciones del mes
  final int transactionCount;

  const MonthlySummaryEntity({
    required this.monthYear,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        monthYear,
        totalIncome,
        totalExpense,
        balance,
        transactionCount,
      ];
}

