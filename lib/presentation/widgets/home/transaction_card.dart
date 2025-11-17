import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/presentation/blocs/home/home_bloc.dart';
import 'package:cashup/presentation/blocs/home/home_event.dart';

/// **TRANSACTION_CARD (Widget de Tarjeta de Transacción)**
/// 
/// Muestra una transacción individual en la lista de movimientos recientes.
/// 
/// **Diseño basado en las imágenes:**
/// - Card blanco con bordes redondeados
/// - Icono de categoría en un círculo gris claro
/// - Título de la transacción en negrita
/// - Fecha formateada (Hoy, Ayer, o fecha completa)
/// - Monto con signo + para ingresos (verde) y sin signo para gastos (rojo)
class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  /// Formatea un número como moneda colombiana
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$ ',
      decimalDigits: 0,
      locale: 'es_CO',
    );
    return formatter.format(amount).replaceAll(',', '.');
  }

  /// Formatea la fecha de la transacción
  /// Retorna "Hoy", "Ayer" o "DD/MM/YYYY"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (transactionDay == today) {
      return AppStrings.today;
    } else if (transactionDay == yesterday) {
      return AppStrings.yesterday;
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Obtiene el icono de la categoría
  /// Si no hay categoría, usa un icono por defecto según el tipo
  String _getCategoryIcon() {
    if (transaction.category != null) {
      return transaction.category!.icon;
    }
    // Iconos por defecto según el tipo
    return transaction.type == TransactionType.income ? '💰' : '🛒';
  }

  /// Obtiene el color de la categoría
  /// Si no hay categoría, usa un color por defecto según el tipo
  Color _getCategoryColor() {
    if (transaction.category != null) {
      // Convertir hex a Color
      final hex = transaction.category!.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }
    // Colores por defecto según el tipo
    return transaction.type == TransactionType.income
        ? AppColors.defaultIncomeCategory
        : AppColors.defaultExpenseCategory;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountText = isIncome
        ? '+${_formatCurrency(transaction.amount)}'
        : _formatCurrency(transaction.amount);

    return InkWell(
      onTap: () async {
        // Navegar a la pantalla de detalle y esperar el resultado
        final result = await context.push('/transaction/${transaction.id}');
        // Si hubo cambios (actualización o eliminación), refrescar la pantalla principal
        if (result == true && context.mounted) {
          // Refrescar los datos del HomeBloc directamente
          context.read<HomeBloc>().add(const HomeDataRefreshed());
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 12.0),
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
        child: Row(
        children: [
          // Icono de categoría en círculo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getCategoryIcon(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Título y fecha
          // Expanded para que el contenido se expanda y ocupe todo el espacio disponible
          Expanded(
            child: Column(
              // CrossAxisAlignment.start para que el contenido se alinee a la izquierda
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.transactionDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Monto
          Text(
            amountText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
        ),
    );
  }
}

