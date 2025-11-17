import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/entities/category_entity.dart';

/// **TRANSACTION_DETAIL_EVENT (Eventos del Detalle de Transacción)**
/// 
/// Eventos que pueden ocurrir en la pantalla de detalle de transacción.
sealed class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializa la pantalla de detalle con una transacción
class TransactionDetailInitialized extends TransactionDetailEvent {
  final String transactionId;

  const TransactionDetailInitialized({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

/// Cambia el modo de edición
class TransactionDetailEditModeChanged extends TransactionDetailEvent {
  final bool isEditing;

  const TransactionDetailEditModeChanged({required this.isEditing});

  @override
  List<Object?> get props => [isEditing];
}

/// Cambia el tipo de transacción
class TransactionDetailTypeChanged extends TransactionDetailEvent {
  final TransactionType type;

  const TransactionDetailTypeChanged({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Cambia el título
class TransactionDetailTitleChanged extends TransactionDetailEvent {
  final String title;

  const TransactionDetailTitleChanged({required this.title});

  @override
  List<Object?> get props => [title];
}

/// Cambia el monto
class TransactionDetailAmountChanged extends TransactionDetailEvent {
  final double amount;

  const TransactionDetailAmountChanged({required this.amount});

  @override
  List<Object?> get props => [amount];
}

/// Cambia la descripción
class TransactionDetailDescriptionChanged extends TransactionDetailEvent {
  final String description;

  const TransactionDetailDescriptionChanged({required this.description});

  @override
  List<Object?> get props => [description];
}

/// Cambia la categoría seleccionada
class TransactionDetailCategorySelected extends TransactionDetailEvent {
  final CategoryEntity? category;

  const TransactionDetailCategorySelected({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Cambia la fecha
class TransactionDetailDateChanged extends TransactionDetailEvent {
  final DateTime date;

  const TransactionDetailDateChanged({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Carga las categorías
class TransactionDetailCategoriesLoaded extends TransactionDetailEvent {
  const TransactionDetailCategoriesLoaded();
}

/// Categoría creada
class TransactionDetailCategoryCreated extends TransactionDetailEvent {
  final CategoryEntity category;

  const TransactionDetailCategoryCreated({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Guarda los cambios
class TransactionDetailSaved extends TransactionDetailEvent {
  const TransactionDetailSaved();
}

/// Elimina la transacción
class TransactionDetailDeleted extends TransactionDetailEvent {
  const TransactionDetailDeleted();
}

