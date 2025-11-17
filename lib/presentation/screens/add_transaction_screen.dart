import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/presentation/blocs/add_transaction/add_transaction_bloc.dart';
import 'package:cashup/presentation/blocs/add_transaction/add_transaction_event.dart';
import 'package:cashup/presentation/blocs/add_transaction/add_transaction_state.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_bloc.dart';
import 'package:cashup/presentation/widgets/add_transaction/category_selection_widget.dart';
import 'package:cashup/presentation/widgets/common/custom_snackbar.dart';
import 'package:cashup/presentation/screens/create_category_screen.dart';

/// **ADD_TRANSACTION_SCREEN (Pantalla de Agregar Transacción)**
/// 
/// Modal bottom sheet que permite agregar una nueva transacción (ingreso o gasto).
/// 
/// **Características:**
/// - Toggle entre ingreso y gasto
/// - Campos: título, monto, descripción, categoría, fecha
/// - Selección de categorías filtradas por tipo
/// - Opción para crear nueva categoría
/// - Validación de campos
class AddTransactionScreen extends StatefulWidget {
  /// Tipo inicial de transacción (income o expense)
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    required this.initialType,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el BLoC de la pantalla de agregar transacción
    return BlocProvider.value(
      // Agregar el evento para inicializar el formulario
      // El AddTransactionInitialized es un evento que se encarga de inicializar el formulario de agregar transacción
      value: context.read<AddTransactionBloc>()
        ..add(AddTransactionInitialized(initialType: widget.initialType)),
      child: BlocConsumer<AddTransactionBloc, AddTransactionState>(
        // Listener para manejar los eventos del BLoC
        listener: (context, state) {
          if (state is AddTransactionSuccess) {
            // Retornar true para indicar éxito
            Navigator.of(context).pop(true); // Retornar true para indicar éxito
            CustomSnackBar.showSuccess(
              context,
              message: AppStrings.transactionSaved,
            );
          } else if (state is AddTransactionError) {
            CustomSnackBar.showError(
              context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is AddTransactionFormReady) {
            return _buildForm(context, state);
          } else if (state is AddTransactionInitial) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddTransactionFormReady state) {
    final isExpense = state.type == TransactionType.expense;
    final primaryColor = isExpense ? AppColors.expense : AppColors.income;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, state, primaryColor),
          
          // Contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle Ingreso/Gasto
                  _buildTypeToggle(context, state, primaryColor),
                  const SizedBox(height: 24),
                  
                  // Campo Título
                  _buildTitleField(context, state),
                  const SizedBox(height: 20),
                  
                  // Campo Monto
                  _buildAmountField(context, state, primaryColor),
                  const SizedBox(height: 20),
                  
                  // Campo Descripción
                  _buildDescriptionField(context, state),
                  const SizedBox(height: 20),
                  
                  // Selección de Categoría
                  _buildCategorySection(context, state),
                  const SizedBox(height: 20),
                  
                  // Campo Fecha
                  _buildDateField(context, state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Botón Guardar
          _buildSaveButton(context, state, primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AddTransactionFormReady state, Color primaryColor) {
    final title = state.type == TransactionType.expense 
        ? AppStrings.newExpense 
        : AppStrings.newIncome;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.shadowColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(BuildContext context, AddTransactionFormReady state, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            context: context,
            label: AppStrings.expenses,
            isSelected: state.type == TransactionType.expense,
            color: AppColors.expense,
            onTap: () {
              context.read<AddTransactionBloc>().add(
                const AddTransactionTypeChanged(type: TransactionType.expense),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            context: context,
            label: AppStrings.income,
            isSelected: state.type == TransactionType.income,
            color: AppColors.income,
            onTap: () {
              context.read<AddTransactionBloc>().add(
                const AddTransactionTypeChanged(type: TransactionType.income),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.indicatorInactive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.indicatorInactive,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(BuildContext context, AddTransactionFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: AppStrings.titlePlaceholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.indicatorInactive),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            context.read<AddTransactionBloc>().add(
              AddTransactionTitleChanged(title: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context, AddTransactionFormReady state, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: '0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.indicatorInactive),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          onChanged: (value) {
            context.read<AddTransactionBloc>().add(
              AddTransactionAmountChanged(amount: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, AddTransactionFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.description,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppStrings.descriptionPlaceholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.indicatorInactive),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (value) {
            context.read<AddTransactionBloc>().add(
              AddTransactionDescriptionChanged(description: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, AddTransactionFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.category,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (state.isLoadingCategories)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          CategorySelectionWidget(
            categories: state.categories,
            selectedCategory: state.selectedCategory,
            onCategorySelected: (category) {
              context.read<AddTransactionBloc>().add(
                AddTransactionCategorySelected(category: category),
              );
            },
            onNewCategoryPressed: () {
              _showCreateCategoryDialog(context, state.type);
            },
          ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, AddTransactionFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, state),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.indicatorInactive),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(state.transactionDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, AddTransactionFormReady state, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.shadowColor),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: state.isSaving || !state.isValid
              ? null
              : () {
                  context.read<AddTransactionBloc>().add(
                    const AddTransactionSubmitted(),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.indicatorInactive,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const Text(
                  AppStrings.save,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, AddTransactionFormReady state) async {
    final bloc = context.read<AddTransactionBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    // Verificar que el widget esté montado antes de usar el BLoC
    if (picked != null && mounted) {
      bloc.add(
        AddTransactionDateChanged(date: picked),
      );
    }
  }

  Future<void> _showCreateCategoryDialog(BuildContext context, TransactionType type) async {
    // Guardar referencia al BLoC antes del await
    final bloc = context.read<AddTransactionBloc>();
    
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => sl<CreateCategoryBloc>(),
        child: CreateCategoryScreen(initialType: type),
      ),
    );

    // Verificar que el widget esté montado antes de usar context
    if (!mounted) return;

    if (result != null && result is Map<String, dynamic> && result['category'] != null) {
      // Recargar categorías para obtener la categoría creada con su ID
      bloc.add(
        const AddTransactionCategoriesLoaded(),
      );
      
      // Esperar un poco para que las categorías se carguen y luego seleccionar la primera
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Verificar nuevamente que el widget esté montado
      if (!mounted) return;
      
      final currentState = bloc.state;
      if (currentState is AddTransactionFormReady && currentState.categories.isNotEmpty) {
        // Seleccionar la primera categoría (la más reciente)
        bloc.add(
          AddTransactionCategorySelected(category: currentState.categories.first),
        );
      }
    }
  }
}

