import 'package:cashup/data/datasources/supabase_category_datasource.dart';
import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/repositories/category_repository.dart';

/// **CATEGORY_REPOSITORY_IMPL (Implementación del Repositorio de Categorías)**
/// 
/// Implementa CategoryRepository usando SupabaseCategoryDataSource.
/// 
/// **Responsabilidades:**
/// - Convierte modelos de datos a entidades de dominio
/// - Maneja errores y los convierte en excepciones de dominio
/// - Actúa como puente entre la capa de datos y el dominio
class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseCategoryDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryEntity>> getCategories({
    TransactionType? type,
  }) async {
    try {
      final models = await _dataSource.getCategories(type: type);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    try {
      final model = await _dataSource.getCategoryById(categoryId);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Error al obtener categoría: $e');
    }
  }

  @override
  Future<CategoryEntity> createCategory({
    required String name,
    required TransactionType type,
    String icon = '📁',
    String color = '#6C5CE7',
  }) async {
    try {
      final model = await _dataSource.createCategory(
        name: name,
        type: type,
        icon: icon,
        color: color,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }
}

