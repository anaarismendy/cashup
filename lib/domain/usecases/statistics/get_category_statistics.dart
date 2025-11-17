import 'package:cashup/domain/repositories/statistics_repository.dart';
import 'package:cashup/domain/entities/category_statistics_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **GET_CATEGORY_STATISTICS (Caso de Uso: Obtener Estadísticas de Categorías)**
/// 
/// Encapsula la lógica de negocio para obtener estadísticas de categorías.
/// 
/// **Responsabilidades:**
/// - Delega al repositorio la obtención de datos
/// - Puede incluir validaciones de negocio si es necesario
class GetCategoryStatistics {
  final StatisticsRepository _repository;

  GetCategoryStatistics(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - startDate: Fecha de inicio (opcional)
  /// - endDate: Fecha de fin (opcional)
  /// - type: Tipo de transacción (opcional)
  /// 
  /// **Retorna:** Lista de estadísticas por categoría
  Future<List<CategoryStatisticsEntity>> call({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    return await _repository.getCategoryStatistics(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }
}

