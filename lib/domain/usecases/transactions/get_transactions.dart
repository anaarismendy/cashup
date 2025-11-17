import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **GET_TRANSACTIONS (Caso de Uso)**
/// 
/// Obtiene las transacciones del usuario autenticado.
/// 
/// **¿Cuándo usarlo?**
/// - Para mostrar la lista de transacciones en la pantalla de home
/// - Para obtener transacciones filtradas por fecha o tipo
/// 
/// **Principio de Responsabilidad Única (SOLID):**
/// Este use case tiene UNA responsabilidad: obtener transacciones
class GetTransactions {
  final TransactionRepository _repository;

  GetTransactions(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - `limit`: Número máximo de transacciones a retornar
  /// - `orderBy`: Campo por el cual ordenar
  /// - `ascending`: Si ordenar ascendente o descendente
  Future<List<TransactionEntity>> call({
    int limit = 10,
    String orderBy = 'transaction_date',
    bool ascending = false,
  }) async {
    return await _repository.getTransactions(
      limit: limit,
      orderBy: orderBy,
      ascending: ascending,
    );
  }
}

