import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CATEGORY_ENTITY (Entidad de Categoría)**
/// 
/// Representa una categoría de transacción en el sistema.
/// Esta es la entidad de DOMINIO (negocio puro), sin dependencias de Supabase.
/// 
/// **Características:**
/// - Puede ser del sistema (predefinida) o del usuario (personalizada)
/// - Tiene un tipo asociado (income o expense)
/// - Incluye icono y color para personalización visual
class CategoryEntity extends Equatable {
  /// ID único de la categoría (UUID)
  final String id;
  
  /// ID del usuario que creó la categoría (null si es del sistema)
  final String? userId;
  
  /// Nombre de la categoría
  final String name;
  
  /// Tipo de transacción (income o expense)
  final TransactionType type;
  
  /// Icono de la categoría (emoji o código de icono)
  final String icon;
  
  /// Color de la categoría en formato hexadecimal (ej: '#6C5CE7')
  final String color;
  
  /// Indica si es una categoría del sistema (predefinida)
  final bool isSystem;
  
  /// Fecha de creación
  final DateTime? createdAt;
  
  /// Última actualización
  final DateTime? updatedAt;

  const CategoryEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    this.icon = '📁',
    this.color = '#6C5CE7',
    this.isSystem = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        icon,
        color,
        isSystem,
        createdAt,
        updatedAt,
      ];

  CategoryEntity copyWith({
    String? id,
    String? userId,
    String? name,
    TransactionType? type,
    String? icon,
    String? color,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

