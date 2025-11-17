import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CREATE_CATEGORY_STATE (Estados del Formulario de Crear Categoría)**
/// 
/// Representa los diferentes estados en los que puede estar el formulario.
sealed class CreateCategoryState extends Equatable {
  const CreateCategoryState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CreateCategoryInitial extends CreateCategoryState {
  const CreateCategoryInitial();
}

/// Formulario listo para usar
class CreateCategoryFormReady extends CreateCategoryState {
  /// Tipo de categoría (income o expense)
  final TransactionType type;
  
  /// Nombre de la categoría
  final String name;
  
  /// Icono seleccionado
  final String icon;
  
  /// Color seleccionado (hex)
  final String color;
  
  /// Indica si está guardando
  final bool isSaving;

  const CreateCategoryFormReady({
    required this.type,
    this.name = '',
    this.icon = '📁',
    this.color = '#6C5CE7',
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [type, name, icon, color, isSaving];

  CreateCategoryFormReady copyWith({
    TransactionType? type,
    String? name,
    String? icon,
    String? color,
    bool? isSaving,
  }) {
    return CreateCategoryFormReady(
      type: type ?? this.type,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// Valida si el formulario está completo
  bool get isValid {
    return name.trim().isNotEmpty;
  }
}

/// Error al guardar
class CreateCategoryError extends CreateCategoryState {
  final String message;

  const CreateCategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Categoría creada exitosamente
class CreateCategorySuccess extends CreateCategoryState {
  final String name;
  final String icon;
  final String color;
  final TransactionType type;

  const CreateCategorySuccess({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [name, icon, color, type];
}

