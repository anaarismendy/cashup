import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_event.dart';
import 'package:cashup/presentation/blocs/auth/auth_state.dart';

/// **FORGOT_PASSWORD_SCREEN (Pantalla de Recuperación de Contraseña)**
/// 
/// Permite a los usuarios solicitar un email para restablecer su contraseña.
/// 
/// **Funcionalidades:**
/// - Envío de email de recuperación
/// - Validación de email
/// - Manejo de estados de carga y errores mediante BLoC
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  //FormKey para el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            // Éxito: Mostrar mensaje y volver al login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.resetPasswordSuccess),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 4),
              ),
            );
            // Esperar 2 segundos y volver al login
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.pop();
              }
            });
          } else if (state is AuthError) {
            // Error: Mostrar mensaje
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.replaceAll('Exception:', '').trim()),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Ícono
                    _buildIcon(),
                    const SizedBox(height: 40),

                    // Título
                    const Text(
                      AppStrings.resetPassword,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtítulo
                    const Text(
                      AppStrings.resetPasswordSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Campo de email
                    _buildEmailField(),
                    const SizedBox(height: 32),

                    // Botón de enviar
                    _buildSendButton(context, isLoading),
                    const SizedBox(height: 24),

                    // Link para volver al login
                    _buildBackToLoginLink(context, isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Ícono de recuperación de contraseña
  Widget _buildIcon() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        size: 50,
        color: AppColors.primary,
      ),
    );
  }

  /// Campo de email
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.fieldRequired;
        }
        if (!value.contains('@')) {
          return AppStrings.emailInvalid;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppStrings.email,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.indicatorInactive),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  /// Botón de enviar
  Widget _buildSendButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleResetPassword(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                AppStrings.sendResetEmail,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Link para volver al login
  Widget _buildBackToLoginLink(BuildContext context, bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : () => context.pop(),
      child: const Text(
        AppStrings.backToLogin,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Maneja el envío del email de recuperación
  void _handleResetPassword(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    // Enviar evento al BLoC
    context.read<AuthBloc>().add(
          AuthPasswordResetRequested(email: email),
        );
  }
}

