import 'package:equatable/equatable.dart';

/// **WEEKLY_SUMMARY_ENTITY (Entidad de Resumen Semanal)**
/// 
/// Representa un resumen de transacciones para una semana específica.
/// Incluye ingresos totales, gastos totales, balance y número de transacciones.
class WeeklySummaryEntity extends Equatable {
  /// Fecha de inicio de la semana
  final DateTime weekStart;
  
  /// Fecha de fin de la semana
  final DateTime weekEnd;
  
  /// Total de ingresos de la semana
  final double totalIncome;
  
  /// Total de gastos de la semana
  final double totalExpense;
  
  /// Balance de la semana (ingresos - gastos)
  final double balance;
  
  /// Número de transacciones de la semana
  final int transactionCount;

  const WeeklySummaryEntity({
    required this.weekStart,
    required this.weekEnd,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        totalIncome,
        totalExpense,
        balance,
        transactionCount,
      ];
}

