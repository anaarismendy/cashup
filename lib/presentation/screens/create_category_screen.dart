import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_bloc.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_event.dart';
import 'package:cashup/presentation/blocs/create_category/create_category_state.dart';
import 'package:cashup/presentation/widgets/common/custom_snackbar.dart';

/// **CREATE_CATEGORY_SCREEN (Pantalla de Crear Categoría)**
/// 
/// Modal bottom sheet que permite crear una nueva categoría personalizada.
/// 
/// **Características:**
/// - Campo de nombre
/// - Toggle entre ingreso y gasto
/// - Selección de icono desde una grilla
/// - Selección de color desde una paleta
/// - Vista previa de la categoría
class CreateCategoryScreen extends StatelessWidget {
  /// Tipo inicial de categoría
  final TransactionType initialType;

  const CreateCategoryScreen({
    super.key,
    required this.initialType,
  });

  // Lista de iconos disponibles
  static const List<String> availableIcons = [
    '🛒', '🚗', '🎬', '💊', '📚', '📦',
    '🏠', '✈️', '🍔', '💰', '💻', '📊', '🎮',
    '🍕', '☕', '🍎', '🥗', '🍰', '🍺', '🍷',
    '🏥', '💊', '💉', '🏋️', '⚽', '🎾', '🏊',
    '🎨', '🎵', '🎸', '🎹', '🎤', '📷', '🎥',
    '📱', '💻', '⌚', '🎧', '🔌', '💡', '🔋',
    '👕', '👔', '👗', '👠', '👜', '💄', '💍',
    '🐕', '🐈', '🐦', '🐠', '🌳', '🌺', '🌸',
    '🎁', '🎈', '🎉', '🎊', '🎀', '🏆', '⭐',
    '💼', '📝', '📋', '📌', '✏️', '🖊️', '📎',
    '🚌', '🚕', '🚇', '🚲', '🛴', '🛵', '🏍️',
    '🌮', '🌯', '🥙', '🍱', '🍣', '🍙', '🍜',
    '🏛️', '🏢', '🏪', '🏨', '🏰', '⛪', '🕌',
    '🎯', '🎲', '🃏', '🀄', '🎴', '🪄', '🎪',
  ];

  // Lista de colores disponibles
  static const List<String> availableColors = [
    // Rojos y rosas
    '#FF6B6B', '#FF8B94', '#FFAAA5', '#FFB6C1', '#FF69B4',
    '#FF1493', '#DC143C', '#C71585', '#FF6347', '#FF4500',
    // Azules y turquesas
    '#4ECDC4', '#00CEC9', '#00B894', '#00CED1', '#20B2AA',
    '#4682B4', '#5F9EA0', '#6495ED', '#4169E1', '#1E90FF',
    '#00BFFF', '#87CEEB', '#87CEFA', '#B0E0E6', '#ADD8E6',
    // Verdes
    '#95E1D3', '#A8E6CF', '#90EE90', '#98FB98', '#00FF7F',
    '#32CD32', '#228B22', '#2E8B57', '#3CB371', '#66CDAA',
    // Amarillos y naranjas
    '#FFE66D', '#FFD3A5', '#FDCB6E', '#FFD700', '#FFA500',
    '#FF8C00', '#FF7F50', '#FFA07A', '#FFB347', '#FFCC33',
    // Morados y púrpuras
    '#6C5CE7', '#A29BFE', '#9370DB', '#BA55D3', '#DA70D6',
    '#DDA0DD', '#EE82EE', '#FF00FF', '#8B008B', '#9400D3',
    // Grises y neutros
    '#708090', '#778899', '#B0C4DE', '#D3D3D3', '#DCDCDC',
    '#F5F5F5', '#F0F8FF', '#FAEBD7', '#FFF8DC', '#FFFAF0',
    // Colores vibrantes adicionales
    '#FF1493', '#00CED1', '#FF4500', '#32CD32', '#FFD700',
    '#FF69B4', '#00BFFF', '#FF6347', '#7FFF00', '#FF1493',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreateCategoryBloc>()
        ..add(CreateCategoryInitialized(initialType: initialType)),
      child: BlocConsumer<CreateCategoryBloc, CreateCategoryState>(
        listener: (context, state) {
          if (state is CreateCategorySuccess) {
            // Retornar la categoría creada
            Navigator.of(context).pop({
              'category': {
                'name': state.name,
                'icon': state.icon,
                'color': state.color,
                'type': state.type,
              },
            });
          } else if (state is CreateCategoryError) {
            CustomSnackBar.showError(
              context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is CreateCategoryFormReady) {
            return _buildForm(context, state);
          } else if (state is CreateCategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, CreateCategoryFormReady state) {
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
          _buildHeader(context),
          
          // Contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo Nombre
                  _buildNameField(context, state),
                  const SizedBox(height: 24),
                  
                  // Toggle Tipo
                  _buildTypeToggle(context, state, primaryColor),
                  const SizedBox(height: 24),
                  
                  // Selección de Icono
                  _buildIconSelection(context, state),
                  const SizedBox(height: 24),
                  
                  // Selección de Color
                  _buildColorSelection(context, state),
                  const SizedBox(height: 24),
                  
                  // Vista Previa
                  _buildPreview(context, state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Botones
          _buildActionButtons(context, state, primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Text(
            AppStrings.newCategoryTitle,
            style: TextStyle(
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

  Widget _buildNameField(BuildContext context, CreateCategoryFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.categoryName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) {
            context.read<CreateCategoryBloc>().add(
              CreateCategoryNameChanged(name: value),
            );
          },
          decoration: InputDecoration(
            hintText: AppStrings.categoryNamePlaceholder,
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
        ),
      ],
    );
  }

  Widget _buildTypeToggle(BuildContext context, CreateCategoryFormReady state, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.type,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                context: context,
                label: AppStrings.expenses,
                isSelected: state.type == TransactionType.expense,
                color: AppColors.expense,
                onTap: () {
                  context.read<CreateCategoryBloc>().add(
                    const CreateCategoryTypeChanged(type: TransactionType.expense),
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
                  context.read<CreateCategoryBloc>().add(
                    const CreateCategoryTypeChanged(type: TransactionType.income),
                  );
                },
              ),
            ),
          ],
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

  Widget _buildIconSelection(BuildContext context, CreateCategoryFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.icon,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final icon = availableIcons[index];
            final isSelected = state.icon == icon;

            return InkWell(
              onTap: () {
                context.read<CreateCategoryBloc>().add(
                  CreateCategoryIconSelected(icon: icon),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.indicatorInactive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.indicatorInactive,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorSelection(BuildContext context, CreateCategoryFormReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.color,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: availableColors.length,
          itemBuilder: (context, index) {
            final colorHex = availableColors[index];
            final hex = colorHex.replaceAll('#', '');
            final color = Color(int.parse('FF$hex', radix: 16));
            final isSelected = state.color == colorHex;

            return InkWell(
              onTap: () {
                context.read<CreateCategoryBloc>().add(
                  CreateCategoryColorSelected(color: colorHex),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.textPrimary : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context, CreateCategoryFormReady state) {
    final hex = state.color.replaceAll('#', '');
    final categoryColor = Color(int.parse('FF$hex', radix: 16));
    final name = state.name.isEmpty ? AppStrings.categoryPreviewName : state.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.preview,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.indicatorInactive),
          ),
          child: Row(
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    state.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Nombre y transacciones
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '0 ${AppStrings.categoryPreviewTransactions}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, CreateCategoryFormReady state, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.shadowColor),
        ),
      ),
      child: Row(
        children: [
          // Botón Cancelar
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.indicatorInactive),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón Guardar
          Expanded(
            child: ElevatedButton(
              onPressed: state.isSaving || !state.isValid
                  ? null
                  : () {
                      context.read<CreateCategoryBloc>().add(
                        const CreateCategorySubmitted(),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.indicatorInactive,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
        ],
      ),
    );
  }
}

