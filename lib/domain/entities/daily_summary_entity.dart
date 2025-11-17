import 'package:equatable/equatable.dart';

/// **DAILY_SUMMARY_ENTITY (Entidad de Resumen Diario)**
/// 
/// Representa un resumen de transacciones para un día específico.
/// Incluye ingresos, gastos, balance y número de transacciones.
class DailySummaryEntity extends Equatable {
  /// ID del usuario
  final String userId;
  
  /// Fecha del resumen
  final DateTime transactionDate;
  
  /// Total de ingresos del día
  final double dailyIncome;
  
  /// Total de gastos del día
  final double dailyExpense;
  
  /// Balance del día (ingresos - gastos)
  final double dailyBalance;
  
  /// Número de transacciones del día
  final int transactionCount;

  const DailySummaryEntity({
    required this.userId,
    required this.transactionDate,
    required this.dailyIncome,
    required this.dailyExpense,
    required this.dailyBalance,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        userId,
        transactionDate,
        dailyIncome,
        dailyExpense,
        dailyBalance,
        transactionCount,
      ];
}

