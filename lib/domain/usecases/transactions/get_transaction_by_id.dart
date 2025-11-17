import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **GET_TRANSACTION_BY_ID (Caso de Uso)**
/// 
/// Obtiene una transacción por su ID.
/// 
/// **¿Cuándo usarlo?**
/// - Cuando necesitas obtener los detalles completos de una transacción específica
class GetTransactionById {
  final TransactionRepository _repository;

  GetTransactionById(this._repository);

  Future<TransactionEntity?> call(String transactionId) async {
    return await _repository.getTransactionById(transactionId);
  }
}

