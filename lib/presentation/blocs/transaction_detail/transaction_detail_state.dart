import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/entities/category_entity.dart';

/// **TRANSACTION_DETAIL_STATE (Estados del Detalle de Transacción)**
/// 
/// Estados posibles de la pantalla de detalle de transacción.
sealed class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial (cargando)
class TransactionDetailInitial extends TransactionDetailState {
  const TransactionDetailInitial();
}

/// Estado de carga
class TransactionDetailLoading extends TransactionDetailState {
  const TransactionDetailLoading();
}

/// Formulario listo para mostrar/editar
class TransactionDetailReady extends TransactionDetailState {
  final TransactionEntity transaction;
  final bool isEditing;
  final String title;
  final double amount;
  final TransactionType type;
  final String description;
  final CategoryEntity? selectedCategory;
  final List<CategoryEntity> categories;
  final DateTime transactionDate;
  final bool isLoadingCategories;
  final bool isSaving;
  final bool isDeleting;

  const TransactionDetailReady({
    required this.transaction,
    this.isEditing = false,
    required this.title,
    required this.amount,
    required this.type,
    required this.description,
    this.selectedCategory,
    required this.categories,
    required this.transactionDate,
    this.isLoadingCategories = false,
    this.isSaving = false,
    this.isDeleting = false,
  });

  TransactionDetailReady copyWith({
    TransactionEntity? transaction,
    bool? isEditing,
    String? title,
    double? amount,
    TransactionType? type,
    String? description,
    CategoryEntity? selectedCategory,
    List<CategoryEntity>? categories,
    DateTime? transactionDate,
    bool? isLoadingCategories,
    bool? isSaving,
    bool? isDeleting,
  }) {
    return TransactionDetailReady(
      transaction: transaction ?? this.transaction,
      isEditing: isEditing ?? this.isEditing,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      transactionDate: transactionDate ?? this.transactionDate,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get isValid => title.isNotEmpty && amount > 0;

  double? get amountValue => amount > 0 ? amount : null;

  @override
  List<Object?> get props => [
        transaction,
        isEditing,
        title,
        amount,
        type,
        description,
        selectedCategory,
        categories,
        transactionDate,
        isLoadingCategories,
        isSaving,
        isDeleting,
      ];
}

/// Estado de éxito al guardar
class TransactionDetailSaveSuccess extends TransactionDetailState {
  const TransactionDetailSaveSuccess();
}

/// Estado de éxito al eliminar
class TransactionDetailDeleteSuccess extends TransactionDetailState {
  const TransactionDetailDeleteSuccess();
}

/// Estado de error
class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

