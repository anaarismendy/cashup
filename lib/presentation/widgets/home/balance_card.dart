import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';

/// **BALANCE_CARD (Widget de Tarjeta de Balance)**
/// 
/// Muestra el balance total, ingresos y gastos del usuario.
/// 
/// **Diseño basado en las imágenes:**
/// - Card blanco con bordes redondeados
/// - Balance total grande y destacado
/// - Ingresos en verde con icono de flecha hacia arriba
/// - Gastos en rojo con icono de flecha hacia abajo
class BalanceCard extends StatelessWidget {
  /// Balance total (ingresos - gastos)
  final double balance;
  
  /// Total de ingresos
  final double totalIncome;
  
  /// Total de gastos
  final double totalExpenses;

  // Constructor de la clase BalanceCard
  const BalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  /// Formatea un número como moneda colombiana 
  String _formatCurrency(double amount) {
    // Formateador de moneda colombiana con el símbolo de peso colombiano
    final formatter = NumberFormat.currency(
      symbol: '\$ ',
      decimalDigits: 0,
      locale: 'es_CO',
    );
    // Reemplaza las comas por puntos para que el formato sea válido en Colombia
    return formatter.format(amount).replaceAll(',', '.');
  }

  // Método build que construye la UI de la tarjeta de balance
  @override
  Widget build(BuildContext context) {
    // Contenedor de la tarjeta de balance
    return Container(
      // Padding para el contenido de la tarjeta de balance
      // 24 para que el contenido de la tarjeta de balance se vea bien
      // Todos los lados
      padding: const EdgeInsets.all(24.0),
      // Decoración de la tarjeta de balance
      // Color blanco
      // Bordes redondeados
      // BoxShadow para que la tarjeta de balance tenga una sombra
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            // Offset para que la sombra se desplace 2 unidades hacia abajo
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Columna para el contenido de la tarjeta de balance
      // CrossAxisAlignment.start para que el contenido se alinee a la izquierda
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Título "Balance Total"
          const Text(
            AppStrings.balanceTotal,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Balance total grande
          Text(
            // Formatea el balance total como moneda colombiana
            _formatCurrency(balance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Ingresos y Gastos lado a lado
          Row(

            children: [
              // Ingresos
              Expanded(
                child: _buildIncomeExpenseRow(
                  label: AppStrings.income,
                  amount: totalIncome,
                  color: AppColors.income,
                  icon: Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 16),
              
              // Gastos
              Expanded(
                child: _buildIncomeExpenseRow(
                  label: AppStrings.expenses,
                  amount: totalExpenses,
                  color: AppColors.expense,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una fila de ingreso o gasto
  Widget _buildIncomeExpenseRow({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        // Icono con fondo de color claro
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        
        // Label y monto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

