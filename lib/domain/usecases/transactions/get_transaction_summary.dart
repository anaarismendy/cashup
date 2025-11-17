import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **GET_TRANSACTION_SUMMARY (Caso de Uso)**
/// 
/// Obtiene el resumen financiero del usuario (balance, ingresos, gastos).
/// 
/// **¿Cuándo usarlo?**
/// - Para mostrar el balance total en la pantalla de home
/// - Para calcular estadísticas financieras
/// 
/// **Retorna:**
/// - `totalIncome`: Suma de todos los ingresos
/// - `totalExpenses`: Suma de todos los gastos
/// - `balance`: Balance total (ingresos - gastos)
class GetTransactionSummary {
  final TransactionRepository _repository;

  GetTransactionSummary(this._repository);

  /// Ejecuta el caso de uso
  Future<Map<String, double>> call() async {
    return await _repository.getTransactionSummary();
  }
}

