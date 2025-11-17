import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **CREATE_TRANSACTION (Caso de Uso)**
/// 
/// Crea una nueva transacción para el usuario autenticado.
/// 
/// **¿Cuándo usarlo?**
/// - Cuando el usuario presiona "+ Ingreso" o "+ Gasto"
/// - Para registrar nuevas transacciones desde cualquier pantalla
class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - `title`: Título de la transacción
  /// - `amount`: Monto (siempre positivo)
  /// - `type`: Tipo de transacción (income o expense)
  /// - `categoryId`: ID de la categoría (opcional)
  /// - `description`: Descripción adicional (opcional)
  /// - `transactionDate`: Fecha de la transacción (default: hoy)
  Future<TransactionEntity> call({
    required String title,
    required double amount,
    required TransactionType type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  }) async {
    return await _repository.createTransaction(
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      description: description,
      transactionDate: transactionDate,
    );
  }
}

