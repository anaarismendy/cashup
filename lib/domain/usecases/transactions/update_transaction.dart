import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **UPDATE_TRANSACTION (Caso de Uso)**
/// 
/// Actualiza una transacción existente.
/// 
/// **¿Cuándo usarlo?**
/// - Cuando el usuario edita los datos de una transacción
class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<TransactionEntity> call({
    required String transactionId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  }) async {
    return await _repository.updateTransaction(
      transactionId: transactionId,
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      description: description,
      transactionDate: transactionDate,
    );
  }
}

