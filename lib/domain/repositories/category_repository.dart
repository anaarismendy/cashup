import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CATEGORY_REPOSITORY (Interfaz de Repositorio de Categorías)**
/// 
/// Define el contrato para todas las operaciones relacionadas con categorías.
/// Esta es una INTERFAZ (abstracción) que será implementada en la capa de datos.
/// 
/// **Principio de Inversión de Dependencias (SOLID):**
/// - El dominio NO depende de la implementación
/// - La implementación depende del dominio
/// - Esto permite cambiar la fuente de datos sin afectar el dominio
abstract class CategoryRepository {
  /// Obtiene todas las categorías disponibles para el usuario
  /// 
  /// **Parámetros:**
  /// - `type`: Filtrar por tipo de transacción (opcional)
  /// 
  /// **Retorna:**
  /// - Categorías del sistema (predefinidas)
  /// - Categorías personalizadas del usuario
  Future<List<CategoryEntity>> getCategories({
    TransactionType? type,
  });

  /// Obtiene una categoría por su ID
  /// 
  /// **Parámetros:**
  /// - `categoryId`: ID de la categoría
  /// 
  /// **Retorna:**
  /// - La categoría si existe, null si no existe
  Future<CategoryEntity?> getCategoryById(String categoryId);

  /// Crea una nueva categoría personalizada
  /// 
  /// **Parámetros:**
  /// - `name`: Nombre de la categoría
  /// - `type`: Tipo de transacción (income o expense)
  /// - `icon`: Icono de la categoría
  /// - `color`: Color en formato hexadecimal
  Future<CategoryEntity> createCategory({
    required String name,
    required TransactionType type,
    String icon,
    String color,
  });
}

