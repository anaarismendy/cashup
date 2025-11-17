import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/domain/usecases/transactions/create_transaction.dart';
import 'package:cashup/domain/usecases/categories/get_categories.dart';
import 'package:cashup/domain/entities/category_entity.dart';
import 'package:cashup/presentation/blocs/add_transaction/add_transaction_event.dart';
import 'package:cashup/presentation/blocs/add_transaction/add_transaction_state.dart';

/// **ADD_TRANSACTION_BLOC**
/// 
/// Maneja toda la lógica de estado del formulario de agregar transacción.
/// 
/// **Responsabilidades:**
/// - Gestionar el estado del formulario (tipo, campos, categorías)
/// - Cargar categorías filtradas por tipo
/// - Validar y guardar transacciones
/// - Manejar cambios entre ingreso y gasto
class AddTransactionBloc extends Bloc<AddTransactionEvent, AddTransactionState> {
  final CreateTransaction _createTransaction;
  final GetCategories _getCategories;

  AddTransactionBloc({
    required CreateTransaction createTransaction,
    required GetCategories getCategories,
  })  : _createTransaction = createTransaction,
        _getCategories = getCategories,
        super(const AddTransactionInitial()) {
    // Registrar handlers de eventos
    on<AddTransactionInitialized>(_onInitialized);
    on<AddTransactionTypeChanged>(_onTypeChanged);
    on<AddTransactionCategoriesLoaded>(_onCategoriesLoaded);
    on<AddTransactionCategorySelected>(_onCategorySelected);
    on<AddTransactionTitleChanged>(_onTitleChanged);
    on<AddTransactionAmountChanged>(_onAmountChanged);
    on<AddTransactionDescriptionChanged>(_onDescriptionChanged);
    on<AddTransactionDateChanged>(_onDateChanged);
    on<AddTransactionCategoryCreated>(_onCategoryCreated);
    on<AddTransactionSubmitted>(_onSubmitted);
  }

  /// Maneja la inicialización del formulario
  Future<void> _onInitialized(
    AddTransactionInitialized event,
    Emitter<AddTransactionState> emit,
  ) async {
    emit(AddTransactionFormReady(
      type: event.initialType,
      transactionDate: DateTime.now(),
    ));

    // Cargar categorías automáticamente
    add(const AddTransactionCategoriesLoaded());
  }

  /// Maneja el cambio de tipo (ingreso/gasto)
  Future<void> _onTypeChanged(
    AddTransactionTypeChanged event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      emit(currentState.copyWith(
        type: event.type,
        selectedCategory: null, // Limpiar categoría seleccionada al cambiar tipo
        isLoadingCategories: true,
      ));

      // Recargar categorías con el nuevo tipo
      add(const AddTransactionCategoriesLoaded());
    }
  }

  /// Maneja la carga de categorías
  Future<void> _onCategoriesLoaded(
    AddTransactionCategoriesLoaded event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      try {
        final categories = await _getCategories(type: currentState.type);
        // Mantener la categoría seleccionada si aún existe en la nueva lista
        final selectedCategoryId = currentState.selectedCategory?.id;
        CategoryEntity? selectedCategory;
        if (selectedCategoryId != null && categories.isNotEmpty) {
          try {
            selectedCategory = categories.firstWhere(
              (c) => c.id == selectedCategoryId,
            );
          } catch (e) {
            // La categoría seleccionada ya no existe, dejar null
            selectedCategory = null;
          }
        }
        
        emit(currentState.copyWith(
          categories: categories,
          isLoadingCategories: false,
          selectedCategory: selectedCategory,
        ));
      } catch (e) {
        emit(AddTransactionError(message: 'Error al cargar categorías: $e'));
      }
    }
  }

  /// Maneja la selección de categoría
  void _onCategorySelected(
    AddTransactionCategorySelected event,
    Emitter<AddTransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  /// Maneja el cambio de título
  void _onTitleChanged(
    AddTransactionTitleChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      emit(currentState.copyWith(title: event.title));
    }
  }

  /// Maneja el cambio de monto
  void _onAmountChanged(
    AddTransactionAmountChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      emit(currentState.copyWith(amount: event.amount));
    }
  }

  /// Maneja el cambio de descripción
  void _onDescriptionChanged(
    AddTransactionDescriptionChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      emit(currentState.copyWith(description: event.description));
    }
  }

  /// Maneja el cambio de fecha
  void _onDateChanged(
    AddTransactionDateChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      emit(currentState.copyWith(transactionDate: event.date));
    }
  }

  /// Maneja cuando se crea una nueva categoría
  void _onCategoryCreated(
    AddTransactionCategoryCreated event,
    Emitter<AddTransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is AddTransactionFormReady) {
      // Agregar la nueva categoría a la lista y seleccionarla
      final updatedCategories = [...currentState.categories, event.category];
      emit(currentState.copyWith(
        categories: updatedCategories,
        selectedCategory: event.category,
      ));
    }
  }

  /// Maneja el envío del formulario
  Future<void> _onSubmitted(
    AddTransactionSubmitted event,
    Emitter<AddTransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AddTransactionFormReady) return;

    // Validar formulario
    if (!currentState.isValid) {
      emit(const AddTransactionError(message: 'Por favor completa todos los campos requeridos'));
      return;
    }

    final amountValue = currentState.amountValue;
    if (amountValue == null || amountValue <= 0) {
      emit(const AddTransactionError(message: 'El monto debe ser mayor a cero'));
      return;
    }

    // Validar que la categoría seleccionada coincida con el tipo de transacción
    if (currentState.selectedCategory != null) {
      if (currentState.selectedCategory!.type != currentState.type) {
        emit(const AddTransactionError(
          message: 'La categoría seleccionada no coincide con el tipo de transacción',
        ));
        return;
      }
    }

    emit(currentState.copyWith(isSaving: true));

    try {
      await _createTransaction(
        title: currentState.title,
        amount: amountValue,
        type: currentState.type,
        categoryId: currentState.selectedCategory?.id,
        description: currentState.description.isEmpty ? null : currentState.description,
        transactionDate: currentState.transactionDate,
      );

      emit(const AddTransactionSuccess());
    } catch (e) {
      emit(AddTransactionError(message: 'Error al guardar transacción: $e'));
    }
  }
}

