import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/domain/entities/category_statistics_entity.dart';

/// **DONUT_CHART_WIDGET (Widget de Gráfica de Donut)**
/// 
/// Muestra una gráfica de donut con la distribución de gastos por categoría.
/// Similar al diseño de las imágenes proporcionadas.
class DonutChartWidget extends StatelessWidget {
  /// Lista de estadísticas por categoría (solo gastos)
  final List<CategoryStatisticsEntity> categoryStatistics;
  
  /// Total de gastos (se muestra en el centro)
  final double totalExpenses;

  const DonutChartWidget({
    super.key,
    required this.categoryStatistics,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar solo gastos para la gráfica
    final expenses = categoryStatistics
        .where((stat) => stat.categoryType.toString().contains('expense'))
        .toList();

    if (expenses.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No hay datos disponibles',
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
            AppStrings.expenseDistribution,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                // Gráfica de donut
                PieChart(
                  PieChartData(
                    sections: _buildSections(expenses),
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Manejar toque en secciones si es necesario
                      },
                    ),
                  ),
                ),
                // Texto en el centro
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        NumberFormat.currency(
                          symbol: '\$',
                          decimalDigits: 0,
                        ).format(totalExpenses),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.total,
                        style: TextStyle(
                          fontSize: 14,
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
      ),
    );
  }

  /// Construye las secciones de la gráfica de donut
  List<PieChartSectionData> _buildSections(
    List<CategoryStatisticsEntity> expenses,
  ) {
    // Colores predefinidos para las categorías
    final colors = [
      const Color(0xFFF44336), // Rojo
      const Color(0xFF00BCD4), // Teal
      const Color(0xFFFFEB3B), // Amarillo
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF9C27B0), // Púrpura
      const Color(0xFFFF9800), // Naranja
      const Color(0xFF2196F3), // Azul
      const Color(0xFFE91E63), // Rosa
    ];

    return expenses.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      
      // Usar el color de la categoría si está disponible, sino usar colores predefinidos
      Color color;
      try {
        // Convertir hex a Color
        final hexColor = stat.categoryColor.replaceAll('#', '');
        color = Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        // Si falla, usar color predefinido
        color = colors[index % colors.length];
      }

      return PieChartSectionData(
        value: stat.totalAmount,
        title: '${stat.percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      );
    }).toList();
  }
}

