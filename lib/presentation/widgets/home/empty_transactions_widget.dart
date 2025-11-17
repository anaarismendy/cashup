import 'package:flutter/material.dart';
import 'package:cashup/core/constants/app_colors.dart';

/// **EMPTY_TRANSACTIONS_WIDGET (Widget de Estado Vacío)**
/// 
/// Muestra un estado vacío cuando no hay transacciones recientes.
/// 
/// **Diseño basado en las imágenes:**
/// - Card blanco con icono centrado
/// - Icono de carrito de compras en gris claro
class EmptyTransactionsWidget extends StatelessWidget {
  const EmptyTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.shopping_cart_outlined,
          size: 64,
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

