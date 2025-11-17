import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';

/// **BOTTOM_NAVIGATION_BAR_WIDGET (Widget de Barra de Navegación Inferior)**
/// 
/// Barra de navegación inferior que permite navegar entre Home y Estadísticas.
/// Similar al diseño de las imágenes proporcionadas.
class BottomNavigationBarWidget extends StatelessWidget {
  /// Ruta actual para determinar qué botón está activo
  final String currentLocation;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón Home
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Inicio',
                route: '/home',
                isActive: currentLocation == '/home',
              ),
              // Botón Estadísticas
              _buildNavItem(
                context: context,
                icon: Icons.bar_chart_rounded,
                label: 'Estadísticas',
                route: '/statistics',
                isActive: currentLocation == '/statistics',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un item de navegación
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

