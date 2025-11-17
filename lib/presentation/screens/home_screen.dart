import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_event.dart';
import 'package:cashup/presentation/blocs/auth/auth_state.dart';

/// **HOME_SCREEN (Pantalla de Inicio)**
/// 
/// Pantalla temporal para verificar que la autenticación funciona correctamente.
/// Muestra información del usuario autenticado y permite cerrar sesión.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Usuario cerró sesión, volver al login
          context.go('/login');
        }
      },
      builder: (context, state) {
        // Obtener usuario del estado
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text('Home'),
            elevation: 0,
            actions: [
              // Botón de logout
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () {
                  // Mostrar confirmación
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
          body: user != null
              ? _buildAuthenticatedContent(context, user)
              : _buildLoadingContent(),
        );
      },
    );
  }

  /// Contenido cuando el usuario está autenticado
  Widget _buildAuthenticatedContent(BuildContext context, dynamic user) {
    final profile = user.profile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Ícono de éxito
            _buildSuccessIcon(),
            const SizedBox(height: 32),

            // Mensaje de bienvenida
            const Text(
              '¡Autenticación Exitosa!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            const Text(
              'Has iniciado sesión correctamente',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Card con información del usuario
            _buildUserInfoCard(profile),
            const SizedBox(height: 32),

            // Botón de cerrar sesión
            _buildLogoutButton(context),
            const SizedBox(height: 16),

            // Nota
            _buildNote(),
          ],
        ),
      ),
    );
  }

  /// Ícono de éxito
  Widget _buildSuccessIcon() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_circle_outline,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  /// Card con información del usuario
  Widget _buildUserInfoCard(dynamic profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Información del Usuario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Datos del usuario
            _buildInfoRow('Nombre completo', profile.fullName),
            const SizedBox(height: 16),
            _buildInfoRow('Email', profile.email),
            const SizedBox(height: 16),
            _buildInfoRow('Fecha de nacimiento', _formatDate(profile.birthDate)),
            const SizedBox(height: 16),
            _buildInfoRow('Edad', '${profile.age ?? 'N/A'} años'),
            if (profile.gender != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow('Género', _formatGender(profile.gender)),
            ],
          ],
        ),
      ),
    );
  }

  /// Fila de información
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Botón de cerrar sesión
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Nota explicativa
  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Esta es una pantalla temporal para verificar la autenticación. Aquí irá el contenido principal de la app.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Contenido de carga
  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  /// Diálogo de confirmación de logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Cerrar sesión?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro que deseas cerrar tu sesión?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Enviar evento de logout al BLoC
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  /// Formatea la fecha
  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Formatea el género
  String _formatGender(String gender) {
    final genderMap = {
      'masculino': 'Masculino',
      'femenino': 'Femenino',
      'otro': 'Otro',
      'prefiero_no_decir': 'Prefiero no decir',
    };
    return genderMap[gender] ?? gender;
  }
}

