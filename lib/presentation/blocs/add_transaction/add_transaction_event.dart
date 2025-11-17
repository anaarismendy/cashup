import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/entities/category_entity.dart';

/// **ADD_TRANSACTION_EVENT (Eventos del Formulario de Transacción)**
/// 
/// Acciones que el usuario puede realizar en el formulario de agregar transacción.
/// 
/// Sealed class para que no se pueda instanciar, solo extendiendo la clase
sealed class AddTransactionEvent extends Equatable {
  const AddTransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializa el formulario con un tipo específico
class AddTransactionInitialized extends AddTransactionEvent {
  final TransactionType initialType;

  const AddTransactionInitialized({required this.initialType});

  @override
  List<Object?> get props => [initialType];
}

/// Cambia el tipo de transacción (ingreso/gasto)
class AddTransactionTypeChanged extends AddTransactionEvent {
  final TransactionType type;

  const AddTransactionTypeChanged({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Carga las categorías disponibles
class AddTransactionCategoriesLoaded extends AddTransactionEvent {
  const AddTransactionCategoriesLoaded();
}

/// Selecciona una categoría
class AddTransactionCategorySelected extends AddTransactionEvent {
  final CategoryEntity? category;

  const AddTransactionCategorySelected({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Actualiza el título de la transacción
class AddTransactionTitleChanged extends AddTransactionEvent {
  final String title;

  const AddTransactionTitleChanged({required this.title});

  @override
  List<Object?> get props => [title];
}

/// Actualiza el monto de la transacción
class AddTransactionAmountChanged extends AddTransactionEvent {
  final String amount;

  const AddTransactionAmountChanged({required this.amount});

  @override
  List<Object?> get props => [amount];
}

/// Actualiza la descripción de la transacción
class AddTransactionDescriptionChanged extends AddTransactionEvent {
  final String description;

  const AddTransactionDescriptionChanged({required this.description});

  @override
  List<Object?> get props => [description];
}

/// Actualiza la fecha de la transacción
class AddTransactionDateChanged extends AddTransactionEvent {
  final DateTime date;

  const AddTransactionDateChanged({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Solicita abrir el formulario de crear categoría
class AddTransactionCreateCategoryRequested extends AddTransactionEvent {
  const AddTransactionCreateCategoryRequested();
}

/// Categoría creada exitosamente
class AddTransactionCategoryCreated extends AddTransactionEvent {
  final CategoryEntity category;

  const AddTransactionCategoryCreated({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Guarda la transacción
class AddTransactionSubmitted extends AddTransactionEvent {
  const AddTransactionSubmitted();
}

/// Cierra el formulario
class AddTransactionClosed extends AddTransactionEvent {
  const AddTransactionClosed();
}

