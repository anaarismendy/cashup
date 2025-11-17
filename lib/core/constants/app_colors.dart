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
}

