import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **DELETE_TRANSACTION (Caso de Uso)**
/// 
/// Elimina una transacción.
/// 
/// **¿Cuándo usarlo?**
/// - Cuando el usuario elimina una transacción
class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<void> call(String transactionId) async {
    return await _repository.deleteTransaction(transactionId);
  }
}

