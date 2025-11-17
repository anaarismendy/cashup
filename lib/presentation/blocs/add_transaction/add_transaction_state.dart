import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/entities/category_entity.dart';

/// **ADD_TRANSACTION_STATE (Estados del Formulario de Transacción)**
/// 
/// Representa los diferentes estados en los que puede estar el formulario.
/// 
/// Sealed class para que no se pueda instanciar, solo extendiendo la clase
sealed class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AddTransactionInitial extends AddTransactionState {
  const AddTransactionInitial();
}

/// Formulario listo para usar
class AddTransactionFormReady extends AddTransactionState {
  /// Tipo de transacción actual (income o expense)
  final TransactionType type;
  
  /// Título de la transacción
  final String title;
  
  /// Monto como string (para el input)
  final String amount;
  
  /// Descripción de la transacción
  final String description;
  
  /// Fecha de la transacción
  final DateTime transactionDate;
  
  /// Categoría seleccionada
  final CategoryEntity? selectedCategory;
  
  /// Lista de categorías disponibles (filtradas por tipo)
  final List<CategoryEntity> categories;
  
  /// Indica si está cargando las categorías
  final bool isLoadingCategories;
  
  /// Indica si está guardando la transacción
  final bool isSaving;

  const AddTransactionFormReady({
    required this.type,
    this.title = '',
    this.amount = '',
    this.description = '',
    required this.transactionDate,
    this.selectedCategory,
    this.categories = const [],
    this.isLoadingCategories = false,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        amount,
        description,
        transactionDate,
        selectedCategory,
        categories,
        isLoadingCategories,
        isSaving,
      ];

  AddTransactionFormReady copyWith({
    TransactionType? type,
    String? title,
    String? amount,
    String? description,
    DateTime? transactionDate,
    CategoryEntity? selectedCategory,
    List<CategoryEntity>? categories,
    bool? isLoadingCategories,
    bool? isSaving,
  }) {
    return AddTransactionFormReady(
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// Valida si el formulario está completo
  bool get isValid {
    return title.isNotEmpty && amount.isNotEmpty && double.tryParse(amount) != null && double.parse(amount) > 0;
  }

  /// Obtiene el monto como double
  double? get amountValue {
    return double.tryParse(amount);
  }
}

/// Error al cargar o guardar
class AddTransactionError extends AddTransactionState {
  final String message;

  const AddTransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Transacción guardada exitosamente
class AddTransactionSuccess extends AddTransactionState {
  const AddTransactionSuccess();
}

