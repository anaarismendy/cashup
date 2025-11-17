import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/presentation/blocs/transaction_detail/transaction_detail_bloc.dart';
import 'package:cashup/presentation/blocs/transaction_detail/transaction_detail_event.dart';
import 'package:cashup/presentation/blocs/transaction_detail/transaction_detail_state.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_bloc.dart';
import 'package:cashup/presentation/widgets/add_transaction/category_selection_widget.dart';
import 'package:cashup/presentation/widgets/common/custom_snackbar.dart';
import 'package:cashup/presentation/screens/create_category_screen.dart';

/// **TRANSACTION_DETAIL_SCREEN (Pantalla de Detalle de Transacción)**
/// 
/// Muestra los detalles de una transacción y permite editarla o eliminarla.
class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TransactionDetailBloc>()
        ..add(TransactionDetailInitialized(transactionId: widget.transactionId)),
      child: BlocConsumer<TransactionDetailBloc, TransactionDetailState>(
        listenWhen: (previous, current) {
          // Escuchar cuando:
          // 1. Se guarda exitosamente (SaveSuccess)
          // 2. Se elimina exitosamente (DeleteSuccess)
          // 3. Hay un error
          // 4. Se sale del modo edición después de guardar (Ready con isEditing=false cuando antes estaba en true)
          return current is TransactionDetailSaveSuccess ||
              current is TransactionDetailDeleteSuccess ||
              current is TransactionDetailError ||
              (previous is TransactionDetailReady && 
               previous.isEditing && 
               current is TransactionDetailReady && 
               !current.isEditing &&
               previous.transaction.id == current.transaction.id);
        },
        listener: (context, state) {
          if (state is TransactionDetailReady) {
            // Se guardó exitosamente y se recargó la transacción
            CustomSnackBar.showSuccess(
              context,
              message: AppStrings.transactionUpdated,
            );
            // Regresar a home después de un delay para que el usuario vea el mensaje y los datos actualizados
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                context.pop(true);
              }
            });
          } else if (state is TransactionDetailSaveSuccess) {
            // Fallback: si no se pudo recargar la transacción pero se guardó
            CustomSnackBar.showSuccess(
              context,
              message: AppStrings.transactionUpdated,
            );
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                context.pop(true);
              }
            });
          } else if (state is TransactionDetailDeleteSuccess) {
            // Mostrar el mensaje primero
            CustomSnackBar.showSuccess(
              context,
              message: AppStrings.transactionDeleted,
            );
            // Regresar inmediatamente a home sin delay para evitar parpadeos
            if (mounted) {
              context.pop(true);
            }
          } else if (state is TransactionDetailError) {
            CustomSnackBar.showError(
              context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionDetailLoading || state is TransactionDetailInitial) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  AppStrings.detail,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is TransactionDetailReady) {
            final isIncome = state.type == TransactionType.income;
            final primaryColor = isIncome ? AppColors.income : AppColors.expense;
            
            // Inicializar controllers solo la primera vez que entramos en modo edición
            if (state.isEditing && !_isInitialized) {
              _titleController.text = state.title;
              _amountController.text = state.amount > 0 
                  ? state.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '') 
                  : '';
              _descriptionController.text = state.description;
              _isInitialized = true;
            } else if (!state.isEditing) {
              // Resetear flag cuando salimos del modo edición
              _isInitialized = false;
            }
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  state.isEditing ? AppStrings.editTransaction : AppStrings.detail,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Icono y título de categoría
                    _buildCategoryHeader(state, primaryColor),
                    const SizedBox(height: 32),
                    
                    // Monto
                    _buildAmount(state, primaryColor),
                    const SizedBox(height: 32),
                    
                    if (state.isEditing) ...[
                      // Formulario de edición
                      _buildEditForm(context, state, primaryColor),
                    ] else ...[
                      // Cards de información
                      _buildInfoCards(state),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Botones de acción
                    if (!state.isEditing)
                      _buildActionButtons(context, state, primaryColor)
                    else
                      _buildSaveButtons(context, state, primaryColor),
                  ],
                ),
              ),
            );
          } else if (state is TransactionDetailDeleteSuccess) {
            // Mientras se procesa la eliminación exitosa, mostrar pantalla de carga
            // El listener ya se encargó de hacer pop, esto es solo para evitar mostrar error
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  AppStrings.detail,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is TransactionDetailError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  AppStrings.detail,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          } else {
            // Estado desconocido - mostrar pantalla de carga
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  AppStrings.detail,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryHeader(TransactionDetailReady state, Color primaryColor) {
    final categoryIcon = state.selectedCategory?.icon ?? 
        (state.type == TransactionType.income ? '💰' : '🛒');
    final categoryColor = state.selectedCategory != null
        ? Color(int.parse('FF${state.selectedCategory!.color.replaceAll('#', '')}', radix: 16))
        : (state.type == TransactionType.income 
            ? AppColors.defaultIncomeCategory 
            : AppColors.defaultExpenseCategory);
    final categoryName = state.selectedCategory?.name ?? 
        (state.type == TransactionType.income ? 'Ingreso' : 'Gasto');

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              categoryIcon,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          categoryName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAmount(TransactionDetailReady state, Color primaryColor) {
    final formatter = NumberFormat.currency(
      symbol: '\$ ',
      decimalDigits: 0,
      locale: 'es_CO',
    );
    final amountText = formatter.format(state.amount).replaceAll(',', '.');

    return Text(
      amountText,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  Widget _buildInfoCards(TransactionDetailReady state) {
    return Column(
      children: [
        // Card Descripción
        _buildInfoCard(
          title: AppStrings.description,
          content: Text(
            state.description.isEmpty 
                ? 'Sin descripción' 
                : state.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Card Categoría
        _buildInfoCard(
          title: AppStrings.category,
          content: Row(
            children: [
              Text(
                state.selectedCategory?.icon ?? '📁',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                state.selectedCategory?.name ?? 'Sin categoría',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Card Fecha
        _buildInfoCard(
          title: AppStrings.date,
          content: Text(
            _formatDateTime(state.transactionDate),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, TransactionDetailReady state, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle Ingreso/Gasto
        _buildTypeToggle(context, state, primaryColor),
        const SizedBox(height: 24),
        
        // Campo Título
        _buildTitleField(context, state),
        const SizedBox(height: 20),
        
        // Campo Monto
        _buildAmountField(context, state),
        const SizedBox(height: 20),
        
        // Campo Descripción
        _buildDescriptionField(context, state),
        const SizedBox(height: 20),
        
        // Selección de Categoría
        _buildCategorySection(context, state),
        const SizedBox(height: 20),
        
        // Campo Fecha
        _buildDateField(context, state),
      ],
    );
  }

  Widget _buildTypeToggle(BuildContext context, TransactionDetailReady state, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            context: context,
            label: AppStrings.expenses,
            isSelected: state.type == TransactionType.expense,
            color: AppColors.expense,
            onTap: () {
              context.read<TransactionDetailBloc>().add(
                const TransactionDetailTypeChanged(type: TransactionType.expense),
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
              context.read<TransactionDetailBloc>().add(
                const TransactionDetailTypeChanged(type: TransactionType.income),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.indicatorInactive,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(BuildContext context, TransactionDetailReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: AppStrings.titlePlaceholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            context.read<TransactionDetailBloc>().add(
              TransactionDetailTitleChanged(title: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context, TransactionDetailReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0.00',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            // Solo actualizar el BLoC si el valor es válido
            if (value.isNotEmpty) {
              final amount = double.tryParse(value);
              if (amount != null && amount > 0) {
                context.read<TransactionDetailBloc>().add(
                  TransactionDetailAmountChanged(amount: amount),
                );
              }
            } else {
              // Si está vacío, actualizar a 0
              context.read<TransactionDetailBloc>().add(
                const TransactionDetailAmountChanged(amount: 0.0),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, TransactionDetailReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppStrings.descriptionPlaceholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            context.read<TransactionDetailBloc>().add(
              TransactionDetailDescriptionChanged(description: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, TransactionDetailReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.category,
          style: TextStyle(
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
              context.read<TransactionDetailBloc>().add(
                TransactionDetailCategorySelected(category: category),
              );
            },
            onNewCategoryPressed: () {
              _showCreateCategoryDialog(context, state.type);
            },
          ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, TransactionDetailReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.date,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(context, state.transactionDate),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TransactionDetailReady state, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildModernButton(
            context: context,
            onPressed: () {
              context.read<TransactionDetailBloc>().add(
                const TransactionDetailEditModeChanged(isEditing: true),
              );
            },
            icon: Icons.edit_rounded,
            label: AppStrings.edit,
            color: AppColors.primary,
            isOutlined: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernButton(
            context: context,
            onPressed: () => _showDeleteConfirmation(context),
            icon: Icons.delete_outline_rounded,
            label: AppStrings.delete,
            color: AppColors.error,
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isOutlined,
  }) {
    if (isOutlined) {
      // Botón outlined con estilo moderno
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Botón sólido con gradiente
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: AppColors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSaveButtons(BuildContext context, TransactionDetailReady state, Color primaryColor) {
    return Column(
      children: [
        // Botón Guardar con gradiente
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: state.isSaving || !state.isValid
                  ? [AppColors.textSecondary.withOpacity(0.5), AppColors.textSecondary.withOpacity(0.3)]
                  : [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: state.isSaving || !state.isValid
                ? []
                : [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: state.isSaving || !state.isValid
                  ? null
                  : () {
                      context.read<TransactionDetailBloc>().add(
                        const TransactionDetailSaved(),
                      );
                    },
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: state.isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          AppStrings.save,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Botón Cancelar con estilo moderno
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.indicatorInactive,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: state.isSaving
                  ? null
                  : () {
                      context.read<TransactionDetailBloc>().add(
                        const TransactionDetailEditModeChanged(isEditing: false),
                      );
                      // Recargar datos originales
                      context.read<TransactionDetailBloc>().add(
                        TransactionDetailInitialized(transactionId: widget.transactionId),
                      );
                    },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      color: state.isSaving
                          ? AppColors.textSecondary.withOpacity(0.5)
                          : AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      context.read<TransactionDetailBloc>().add(
        TransactionDetailDateChanged(date: picked),
      );
    }
  }

  Future<void> _showCreateCategoryDialog(BuildContext context, TransactionType type) async {
    final bloc = context.read<TransactionDetailBloc>();
    
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => sl<CreateCategoryBloc>(),
        child: CreateCategoryScreen(initialType: type),
      ),
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic> && result['category'] != null) {
      bloc.add(const TransactionDetailCategoriesLoaded());
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Capturar el BLoC antes de mostrar el diálogo para evitar problemas de contexto
    final bloc = context.read<TransactionDetailBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(
                const TransactionDetailDeleted(),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (transactionDay == today) {
      return AppStrings.today;
    } else if (transactionDay == yesterday) {
      return AppStrings.yesterday;
    } else {
      // Usar formato sin locale específico para evitar error de inicialización
      // Formato: "dd de MMM, yyyy" (ej: "15 de Ene, 2024")
      final day = date.day.toString().padLeft(2, '0');
      final monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      final month = monthNames[date.month - 1];
      final year = date.year;
      return '$day de $month, $year';
    }
  }
}

