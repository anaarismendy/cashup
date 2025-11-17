import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/domain/entities/category_statistics_entity.dart';

/// **CATEGORY_PROGRESS_LIST_WIDGET (Widget de Lista de Progreso por Categoría)**
/// 
/// Muestra una lista de categorías con barras de progreso.
/// Similar al diseño de "Gastos por Categoría" de las imágenes.
class CategoryProgressListWidget extends StatelessWidget {
  /// Lista de estadísticas por categoría (solo gastos)
  final List<CategoryStatisticsEntity> categoryStatistics;

  const CategoryProgressListWidget({
    super.key,
    required this.categoryStatistics,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar solo gastos
    final expenses = categoryStatistics
        .where((stat) => stat.categoryType.toString().contains('expense'))
        .toList();

    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No hay gastos registrados',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.expensesByCategory,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...expenses.map((stat) => _buildCategoryItem(stat)),
        ],
      ),
    );
  }

  /// Construye un item de categoría con barra de progreso
  Widget _buildCategoryItem(CategoryStatisticsEntity stat) {
    // Colores predefinidos
    final colors = [
      const Color(0xFFF44336), // Rojo
      const Color(0xFF00BCD4), // Teal
      const Color(0xFFFFEB3B), // Amarillo
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF9C27B0), // Púrpura
    ];

    Color color;
    try {
      final hexColor = stat.categoryColor.replaceAll('#', '');
      color = Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      color = colors[stat.categoryId.hashCode % colors.length];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icono de la categoría
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    stat.categoryIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre de la categoría
              Expanded(
                child: Text(
                  stat.categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Monto y porcentaje
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: '\$',
                      decimalDigits: 0,
                    ).format(stat.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${stat.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.percentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.indicatorInactive,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

