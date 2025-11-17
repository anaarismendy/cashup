import 'package:flutter/material.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/domain/entities/category_entity.dart';

/// **CATEGORY_SELECTION_WIDGET (Widget de Selección de Categorías)**
/// 
/// Muestra una grilla de categorías disponibles y permite seleccionar una.
/// Incluye un botón especial para crear una nueva categoría.
class CategorySelectionWidget extends StatelessWidget {
  /// Lista de categorías disponibles
  final List<CategoryEntity> categories;
  
  /// Categoría actualmente seleccionada
  final CategoryEntity? selectedCategory;
  
  /// Callback cuando se selecciona una categoría
  final Function(CategoryEntity?) onCategorySelected;
  
  /// Callback cuando se presiona el botón de nueva categoría
  final VoidCallback onNewCategoryPressed;

  const CategorySelectionWidget({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.onNewCategoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length + 1, // +1 para el botón "Nueva"
      itemBuilder: (context, index) {
        if (index == categories.length) {
          // Botón "Nueva Categoría"
          return _buildNewCategoryButton();
        }
        
        final category = categories[index];
        final isSelected = selectedCategory?.id == category.id;
        
        return _buildCategoryCard(category, isSelected);
      },
    );
  }

  /// Construye una tarjeta de categoría
  Widget _buildCategoryCard(CategoryEntity category, bool isSelected) {
    // Convertir hex a Color
    final hex = category.color.replaceAll('#', '');
    final categoryColor = Color(int.parse('FF$hex', radix: 16));

    return InkWell(
      onTap: () => onCategorySelected(isSelected ? null : category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? categoryColor.withValues(alpha: 0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? categoryColor : AppColors.indicatorInactive,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón "Nueva Categoría"
  Widget _buildNewCategoryButton() {
    return InkWell(
      onTap: onNewCategoryPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de más
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            // Texto "Nueva"
            Text(
              AppStrings.newCategory,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

