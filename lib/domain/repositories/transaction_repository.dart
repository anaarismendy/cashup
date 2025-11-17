import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **TRANSACTION_REPOSITORY (Interfaz de Repositorio de Transacciones)**
/// 
/// Define el contrato para todas las operaciones relacionadas con transacciones.
/// Esta es una INTERFAZ (abstracción) que será implementada en la capa de datos.
/// 
/// **Principio de Inversión de Dependencias (SOLID):**
/// - El dominio NO depende de la implementación
/// - La implementación depende del dominio
/// - Esto permite cambiar la fuente de datos sin afectar el dominio
abstract class TransactionRepository {
  /// Obtiene todas las transacciones del usuario autenticado
  /// 
  /// **Parámetros:**
  /// - `limit`: Número máximo de transacciones a retornar
  /// - `orderBy`: Campo por el cual ordenar
  /// - `ascending`: Si ordenar ascendente o descendente
  Future<List<TransactionEntity>> getTransactions({
    int limit = 10,
    String orderBy = 'transaction_date',
    bool ascending = false,
  });

  /// Crea una nueva transacción
  /// 
  /// **Parámetros:**
  /// - `title`: Título de la transacción
  /// - `amount`: Monto (siempre positivo)
  /// - `type`: Tipo de transacción (income o expense)
  /// - `categoryId`: ID de la categoría (opcional)
  /// - `description`: Descripción adicional (opcional)
  /// - `transactionDate`: Fecha de la transacción
  Future<TransactionEntity> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  });

  /// Obtiene el resumen financiero del usuario
  /// 
  /// **Retorna:**
  /// - `totalIncome`: Suma de todos los ingresos
  /// - `totalExpenses`: Suma de todos los gastos
  /// - `balance`: Balance total (ingresos - gastos)
  Future<Map<String, double>> getTransactionSummary();

  /// Obtiene transacciones recientes (últimas N transacciones)
  /// 
  /// **Parámetros:**
  /// - `limit`: Número de transacciones a retornar
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 5});

  /// Obtiene una transacción por su ID
  /// 
  /// **Parámetros:**
  /// - `transactionId`: ID de la transacción a obtener
  Future<TransactionEntity?> getTransactionById(String transactionId);

  /// Actualiza una transacción existente
  /// 
  /// **Parámetros:**
  /// - `transactionId`: ID de la transacción a actualizar
  /// - `title`: Nuevo título (opcional)
  /// - `amount`: Nuevo monto (opcional)
  /// - `type`: Nuevo tipo (opcional)
  /// - `categoryId`: Nuevo ID de categoría (opcional, puede ser null)
  /// - `description`: Nueva descripción (opcional, puede ser null)
  /// - `transactionDate`: Nueva fecha (opcional)
  Future<TransactionEntity> updateTransaction({
    required String transactionId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  });

  /// Elimina una transacción
  /// 
  /// **Parámetros:**
  /// - `transactionId`: ID de la transacción a eliminar
  Future<void> deleteTransaction(String transactionId);
}

