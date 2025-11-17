import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CREATE_CATEGORY_EVENT (Eventos del Formulario de Crear Categoría)**
/// 
/// Acciones que el usuario puede realizar en el formulario de crear categoría.
sealed class CreateCategoryEvent extends Equatable {
  const CreateCategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializa el formulario con un tipo específico
class CreateCategoryInitialized extends CreateCategoryEvent {
  final TransactionType initialType;

  const CreateCategoryInitialized({required this.initialType});

  @override
  List<Object?> get props => [initialType];
}

/// Cambia el tipo de categoría (ingreso/gasto)
class CreateCategoryTypeChanged extends CreateCategoryEvent {
  final TransactionType type;

  const CreateCategoryTypeChanged({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Actualiza el nombre de la categoría
class CreateCategoryNameChanged extends CreateCategoryEvent {
  final String name;

  const CreateCategoryNameChanged({required this.name});

  @override
  List<Object?> get props => [name];
}

/// Selecciona un icono
class CreateCategoryIconSelected extends CreateCategoryEvent {
  final String icon;

  const CreateCategoryIconSelected({required this.icon});

  @override
  List<Object?> get props => [icon];
}

/// Selecciona un color
class CreateCategoryColorSelected extends CreateCategoryEvent {
  final String color;

  const CreateCategoryColorSelected({required this.color});

  @override
  List<Object?> get props => [color];
}

/// Guarda la categoría
class CreateCategorySubmitted extends CreateCategoryEvent {
  const CreateCategorySubmitted();
}

/// Cierra el formulario
class CreateCategoryClosed extends CreateCategoryEvent {
  const CreateCategoryClosed();
}

