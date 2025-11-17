import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashup/data/models/category_model.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **SUPABASE_CATEGORY_DATASOURCE**
/// 
/// Clase que maneja TODAS las interacciones con la tabla `categories` de Supabase.
/// 
/// **Responsabilidades:**
/// - Obtener categorías del sistema y del usuario
/// - Crear nuevas categorías personalizadas
/// - Filtrar categorías por tipo (income/expense)
class SupabaseCategoryDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseCategoryDataSource(this._supabaseClient);

  /// Obtiene todas las categorías disponibles para el usuario
  /// 
  /// **Retorna:**
  /// - Categorías del sistema (predefinidas)
  /// - Categorías personalizadas del usuario
  Future<List<CategoryModel>> getCategories({
    TransactionType? type,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener categorías del sistema (is_system = true, user_id = null)
      // Y categorías del usuario (user_id = userId)
      var query = _supabaseClient
          .from('categories')
          .select()
          .or('is_system.eq.true,user_id.eq.$userId');

      // Filtrar por tipo si se especifica
      if (type != null) {
        query = query.eq('type', type.toJson());
      }

      final response = await query.order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener categorías: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Obtiene una categoría por su ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      if (response == null) return null;

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener categoría: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Crea una nueva categoría personalizada
  /// 
  /// **Parámetros:**
  /// - `name`: Nombre de la categoría
  /// - `type`: Tipo de transacción (income o expense)
  /// - `icon`: Icono de la categoría (default: '📁')
  /// - `color`: Color en formato hexadecimal (default: '#6C5CE7')
  Future<CategoryModel> createCategory({
    required String name,
    required TransactionType type,
    String icon = '📁',
    String color = '#6C5CE7',
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabaseClient
          .from('categories')
          .insert({
            'user_id': userId,
            'name': name,
            'type': type.toJson(),
            'icon': icon,
            'color': color,
            'is_system': false,
          })
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.message.contains('unique_user_category')) {
        throw Exception('Ya existe una categoría con ese nombre y tipo');
      }
      throw Exception('Error al crear categoría: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}

