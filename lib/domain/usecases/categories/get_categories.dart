import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/repositories/category_repository.dart';

/// **GET_CATEGORIES (Caso de Uso)**
/// 
/// Obtiene todas las categorías disponibles para el usuario.
/// 
/// **¿Cuándo usarlo?**
/// - Para mostrar categorías en un selector
/// - Para filtrar transacciones por categoría
/// - Para mostrar iconos y colores de categorías
class GetCategories {
  final CategoryRepository _repository;

  GetCategories(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - `type`: Filtrar por tipo de transacción (opcional)
  Future<List<CategoryEntity>> call({TransactionType? type}) async {
    return await _repository.getCategories(type: type);
  }
}

