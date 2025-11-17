import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/domain/usecases/transactions/get_transaction_by_id.dart';
import 'package:cashup/domain/usecases/transactions/update_transaction.dart';
import 'package:cashup/domain/usecases/transactions/delete_transaction.dart';
import 'package:cashup/domain/usecases/categories/get_categories.dart';
import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/presentation/blocs/transaction_detail/transaction_detail_event.dart';
import 'package:cashup/presentation/blocs/transaction_detail/transaction_detail_state.dart';

/// **TRANSACTION_DETAIL_BLOC**
/// 
/// Maneja la lógica de estado del detalle y edición de transacción.
class TransactionDetailBloc extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final GetTransactionById _getTransactionById;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetCategories _getCategories;

  TransactionDetailBloc({
    required GetTransactionById getTransactionById,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required GetCategories getCategories,
  })  : _getTransactionById = getTransactionById,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _getCategories = getCategories,
        super(const TransactionDetailInitial()) {
    on<TransactionDetailInitialized>(_onInitialized);
    on<TransactionDetailEditModeChanged>(_onEditModeChanged);
    on<TransactionDetailTypeChanged>(_onTypeChanged);
    on<TransactionDetailTitleChanged>(_onTitleChanged);
    on<TransactionDetailAmountChanged>(_onAmountChanged);
    on<TransactionDetailDescriptionChanged>(_onDescriptionChanged);
    on<TransactionDetailCategorySelected>(_onCategorySelected);
    on<TransactionDetailDateChanged>(_onDateChanged);
    on<TransactionDetailCategoriesLoaded>(_onCategoriesLoaded);
    on<TransactionDetailCategoryCreated>(_onCategoryCreated);
    on<TransactionDetailSaved>(_onSaved);
    on<TransactionDetailDeleted>(_onDeleted);
  }

  /// Maneja la inicialización
  Future<void> _onInitialized(
    TransactionDetailInitialized event,
    Emitter<TransactionDetailState> emit,
  ) async {
    emit(const TransactionDetailLoading());

    try {
      final transaction = await _getTransactionById(event.transactionId);
      if (transaction == null) {
        emit(const TransactionDetailError(message: 'Transacción no encontrada'));
        return;
      }

      // Cargar categorías del tipo de la transacción
      final categories = await _getCategories(type: transaction.type);

      emit(TransactionDetailReady(
        transaction: transaction,
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        description: transaction.description ?? '',
        selectedCategory: transaction.category,
        categories: categories,
        transactionDate: transaction.transactionDate,
      ));
    } catch (e) {
      emit(TransactionDetailError(message: 'Error al cargar transacción: $e'));
    }
  }

  /// Maneja el cambio de modo de edición
  void _onEditModeChanged(
    TransactionDetailEditModeChanged event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(isEditing: event.isEditing));
    }
  }

  /// Maneja el cambio de tipo
  Future<void> _onTypeChanged(
    TransactionDetailTypeChanged event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(
        type: event.type,
        isLoadingCategories: true,
      ));

      try {
        final categories = await _getCategories(type: event.type);
        final selectedCategoryId = currentState.selectedCategory?.id;
        CategoryEntity? selectedCategory;
        if (selectedCategoryId != null && categories.isNotEmpty) {
          try {
            selectedCategory = categories.firstWhere(
              (c) => c.id == selectedCategoryId,
            );
          } catch (e) {
            selectedCategory = null;
          }
        }

        emit(currentState.copyWith(
          type: event.type,
          categories: categories,
          isLoadingCategories: false,
          selectedCategory: selectedCategory,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingCategories: false));
      }
    }
  }

  /// Maneja el cambio de título
  void _onTitleChanged(
    TransactionDetailTitleChanged event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(title: event.title));
    }
  }

  /// Maneja el cambio de monto
  void _onAmountChanged(
    TransactionDetailAmountChanged event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(amount: event.amount));
    }
  }

  /// Maneja el cambio de descripción
  void _onDescriptionChanged(
    TransactionDetailDescriptionChanged event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(description: event.description));
    }
  }

  /// Maneja la selección de categoría
  void _onCategorySelected(
    TransactionDetailCategorySelected event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  /// Maneja el cambio de fecha
  void _onDateChanged(
    TransactionDetailDateChanged event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(transactionDate: event.date));
    }
  }

  /// Maneja la carga de categorías
  Future<void> _onCategoriesLoaded(
    TransactionDetailCategoriesLoaded event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      emit(currentState.copyWith(isLoadingCategories: true));

      try {
        final categories = await _getCategories(type: currentState.type);
        final selectedCategoryId = currentState.selectedCategory?.id;
        CategoryEntity? selectedCategory;
        if (selectedCategoryId != null && categories.isNotEmpty) {
          try {
            selectedCategory = categories.firstWhere(
              (c) => c.id == selectedCategoryId,
            );
          } catch (e) {
            selectedCategory = null;
          }
        }

        emit(currentState.copyWith(
          categories: categories,
          isLoadingCategories: false,
          selectedCategory: selectedCategory,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingCategories: false));
      }
    }
  }

  /// Maneja cuando se crea una nueva categoría
  void _onCategoryCreated(
    TransactionDetailCategoryCreated event,
    Emitter<TransactionDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionDetailReady) {
      final updatedCategories = [...currentState.categories, event.category];
      emit(currentState.copyWith(
        categories: updatedCategories,
        selectedCategory: event.category,
      ));
    }
  }

  /// Maneja el guardado
  Future<void> _onSaved(
    TransactionDetailSaved event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionDetailReady || !currentState.isEditing) return;

    if (!currentState.isValid) {
      emit(const TransactionDetailError(message: 'Por favor completa todos los campos requeridos'));
      return;
    }

    final amountValue = currentState.amountValue;
    if (amountValue == null || amountValue <= 0) {
      emit(const TransactionDetailError(message: 'El monto debe ser mayor a cero'));
      return;
    }

    // Validar que la categoría coincida con el tipo
    if (currentState.selectedCategory != null) {
      if (currentState.selectedCategory!.type != currentState.type) {
        emit(const TransactionDetailError(
          message: 'La categoría seleccionada no coincide con el tipo de transacción',
        ));
        return;
      }
    }

    emit(currentState.copyWith(isSaving: true));

    try {
      await _updateTransaction(
        transactionId: currentState.transaction.id,
        title: currentState.title,
        amount: amountValue,
        type: currentState.type,
        categoryId: currentState.selectedCategory?.id,
        description: currentState.description.isEmpty ? null : currentState.description,
        transactionDate: currentState.transactionDate,
      );

      // Recargar la transacción actualizada
      final updatedTransaction = await _getTransactionById(currentState.transaction.id);
      if (updatedTransaction != null) {
        emit(TransactionDetailReady(
          transaction: updatedTransaction,
          isEditing: false,
          title: updatedTransaction.title,
          amount: updatedTransaction.amount,
          type: updatedTransaction.type,
          description: updatedTransaction.description ?? '',
          selectedCategory: updatedTransaction.category,
          categories: currentState.categories,
          transactionDate: updatedTransaction.transactionDate,
        ));
      } else {
        emit(const TransactionDetailSaveSuccess());
      }
    } catch (e) {
      emit(TransactionDetailError(message: 'Error al guardar transacción: $e'));
    }
  }

  /// Maneja la eliminación
  Future<void> _onDeleted(
    TransactionDetailDeleted event,
    Emitter<TransactionDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionDetailReady) return;

    emit(currentState.copyWith(isDeleting: true));

    try {
      await _deleteTransaction(currentState.transaction.id);
      emit(const TransactionDetailDeleteSuccess());
    } catch (e) {
      emit(TransactionDetailError(message: 'Error al eliminar transacción: $e'));
    }
  }
}

