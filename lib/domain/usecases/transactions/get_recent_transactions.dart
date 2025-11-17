import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **GET_RECENT_TRANSACTIONS (Caso de Uso)**
/// 
/// Obtiene las transacciones más recientes del usuario.
/// 
/// **¿Cuándo usarlo?**
/// - Para mostrar las últimas transacciones en la pantalla de home
/// - Para mostrar un resumen rápido de actividad reciente
class GetRecentTransactions {
  final TransactionRepository _repository;

  GetRecentTransactions(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - `limit`: Número de transacciones a retornar (default: 5)
  Future<List<TransactionEntity>> call({int limit = 5}) async {
    return await _repository.getRecentTransactions(limit: limit);
  }
}

