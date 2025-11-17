import 'package:flutter/material.dart';

class AppColors {
  // Constructor privado para evitar instanciación
  // Solo queremos usar esta clase para acceder a constantes estáticas
  AppColors._();

  // Color principal de la app (verde turquesa de tus imágenes)
  static const Color primary = Color(0xFFFF8FE8);
  
  // Color secundario
  static const Color secondary = Color(0xFFDA8AF2);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Colores de fondo
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  
  // Colores de estado
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFFFF8FE8);
  
  // Colores para los indicadores de página
  static const Color indicatorActive = Color(0xFFFF8FE8);
  static const Color indicatorInactive = Color(0xFFE0E0E0);
  
  // Colores de transacciones
  /// Color verde para ingresos
  static const Color income = Color(0xFF4CAF50);
  
  /// Color rojo para gastos
  static const Color expense = Color(0xFFF44336);
  
  // Colores por defecto para categorías
  /// Color ámbar para categorías de ingreso sin categoría asignada
  static const Color defaultIncomeCategory = Color(0xFFFFC107);
  
  /// Color púrpura para categorías de gasto sin categoría asignada
  static const Color defaultExpenseCategory = Color(0xFF9C27B0);
  
  // Colores neutros
  /// Color blanco puro
  static const Color white = Colors.white;
  
  /// Color negro puro
  static const Color black = Colors.black;
  
  // Colores de sombra
  /// Color negro con opacidad para sombras
  static final Color shadowColor = Colors.black.withValues(alpha: 0.05);
}

