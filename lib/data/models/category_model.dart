import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CATEGORY_MODEL (Modelo de Categoría)**
/// 
/// Modelo de datos que extiende CategoryEntity.
/// Se encarga de la conversión entre JSON (Supabase) y entidades de dominio.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    super.userId,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    super.isSystem,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un CategoryModel desde JSON de Supabase
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      type: TransactionType.fromString(json['type'] as String),
      icon: json['icon'] as String? ?? '📁',
      color: json['color'] as String? ?? '#6C5CE7',
      isSystem: json['is_system'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.toJson(),
      'icon': icon,
      'color': color,
      'is_system': isSystem,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convierte desde la entidad de dominio al modelo
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
      color: entity.color,
      isSystem: entity.isSystem,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte el modelo a entidad de dominio
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      isSystem: isSystem,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

