import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/domain/usecases/categories/create_category.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_event.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_state.dart';

/// **CREATE_CATEGORY_BLOC**
/// 
/// Maneja toda la lógica de estado del formulario de crear categoría.
class CreateCategoryBloc extends Bloc<CreateCategoryEvent, CreateCategoryState> {
  final CreateCategory _createCategory;

  CreateCategoryBloc({
    required CreateCategory createCategory,
  })  : _createCategory = createCategory,
        super(const CreateCategoryInitial()) {
    // Registrar handlers de eventos
    on<CreateCategoryInitialized>(_onInitialized);
    on<CreateCategoryTypeChanged>(_onTypeChanged);
    on<CreateCategoryNameChanged>(_onNameChanged);
    on<CreateCategoryIconSelected>(_onIconSelected);
    on<CreateCategoryColorSelected>(_onColorSelected);
    on<CreateCategorySubmitted>(_onSubmitted);
  }

  /// Maneja la inicialización del formulario
  void _onInitialized(
    CreateCategoryInitialized event,
    Emitter<CreateCategoryState> emit,
  ) {
    emit(CreateCategoryFormReady(
      type: event.initialType,
    ));
  }

  /// Maneja el cambio de tipo
  void _onTypeChanged(
    CreateCategoryTypeChanged event,
    Emitter<CreateCategoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CreateCategoryFormReady) {
      emit(currentState.copyWith(type: event.type));
    }
  }

  /// Maneja el cambio de nombre
  void _onNameChanged(
    CreateCategoryNameChanged event,
    Emitter<CreateCategoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CreateCategoryFormReady) {
      emit(currentState.copyWith(name: event.name));
    }
  }

  /// Maneja la selección de icono
  void _onIconSelected(
    CreateCategoryIconSelected event,
    Emitter<CreateCategoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CreateCategoryFormReady) {
      emit(currentState.copyWith(icon: event.icon));
    }
  }

  /// Maneja la selección de color
  void _onColorSelected(
    CreateCategoryColorSelected event,
    Emitter<CreateCategoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CreateCategoryFormReady) {
      emit(currentState.copyWith(color: event.color));
    }
  }

  /// Maneja el envío del formulario
  Future<void> _onSubmitted(
    CreateCategorySubmitted event,
    Emitter<CreateCategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CreateCategoryFormReady) return;

    // Validar formulario
    if (!currentState.isValid) {
      emit(const CreateCategoryError(message: 'El nombre es requerido'));
      return;
    }

    emit(currentState.copyWith(isSaving: true));

    try {
      final category = await _createCategory(
        name: currentState.name.trim(),
        type: currentState.type,
        icon: currentState.icon,
        color: currentState.color,
      );

      emit(CreateCategorySuccess(
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
      ));
    } catch (e) {
      emit(CreateCategoryError(message: 'Error al crear categoría: $e'));
    }
  }
}

