import 'package:cashup/data/datasources/supabase_transaction_datasource.dart';
import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/repositories/transaction_repository.dart';

/// **TRANSACTION_REPOSITORY_IMPL (Implementación del Repositorio de Transacciones)**
/// 
/// Implementa TransactionRepository usando SupabaseTransactionDataSource.
/// 
/// **Responsabilidades:**
/// - Convierte modelos de datos a entidades de dominio
/// - Maneja errores y los convierte en excepciones de dominio
/// - Actúa como puente entre la capa de datos y el dominio
class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseTransactionDataSource _dataSource;

  TransactionRepositoryImpl(this._dataSource);

  @override
  Future<List<TransactionEntity>> getTransactions({
    int limit = 10,
    String orderBy = 'transaction_date',
    bool ascending = false,
  }) async {
    try {
      final models = await _dataSource.getTransactions(
        limit: limit,
        orderBy: orderBy,
        ascending: ascending,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener transacciones: $e');
    }
  }

  @override
  Future<TransactionEntity> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  }) async {
    try {
      final model = await _dataSource.createTransaction(
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        description: description,
        transactionDate: transactionDate,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Error al crear transacción: $e');
    }
  }

  @override
  Future<Map<String, double>> getTransactionSummary() async {
    try {
      return await _dataSource.getTransactionSummary();
    } catch (e) {
      throw Exception('Error al obtener resumen: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 5}) async {
    try {
      final models = await _dataSource.getRecentTransactions(limit: limit);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener transacciones recientes: $e');
    }
  }

  @override
  Future<TransactionEntity?> getTransactionById(String transactionId) async {
    try {
      final model = await _dataSource.getTransactionById(transactionId);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Error al obtener transacción: $e');
    }
  }

  @override
  Future<TransactionEntity> updateTransaction({
    required String transactionId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  }) async {
    try {
      final model = await _dataSource.updateTransaction(
        transactionId: transactionId,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        description: description,
        transactionDate: transactionDate,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Error al actualizar transacción: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _dataSource.deleteTransaction(transactionId);
    } catch (e) {
      throw Exception('Error al eliminar transacción: $e');
    }
  }
}

