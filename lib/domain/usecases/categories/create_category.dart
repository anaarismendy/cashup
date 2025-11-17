import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/repositories/category_repository.dart';

/// **CREATE_CATEGORY (Caso de Uso)**
/// 
/// Crea una nueva categoría personalizada para el usuario.
/// 
/// **¿Cuándo usarlo?**
/// - Cuando el usuario quiere crear una categoría personalizada
/// - Desde el formulario de agregar transacción
class CreateCategory {
  final CategoryRepository _repository;

  CreateCategory(this._repository);

  /// Ejecuta el caso de uso
  /// 
  /// **Parámetros:**
  /// - `name`: Nombre de la categoría
  /// - `type`: Tipo de transacción (income o expense)
  /// - `icon`: Icono de la categoría (emoji o código)
  /// - `color`: Color en formato hexadecimal
  Future<CategoryEntity> call({
    required String name,
    required TransactionType type,
    String icon = '📁',
    String color = '#6C5CE7',
  }) async {
    return await _repository.createCategory(
      name: name,
      type: type,
      icon: icon,
      color: color,
    );
  }
}

