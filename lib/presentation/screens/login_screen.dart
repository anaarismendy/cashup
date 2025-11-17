import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_event.dart';
import 'package:cashup/presentation/blocs/auth/auth_state.dart';
import 'package:cashup/presentation/widgets/common/custom_snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


/// **LOGIN_SCREEN (Pantalla de Login)**
/// 
/// Permite a usuarios existentes iniciar sesión en la aplicación.
/// 
/// **Funcionalidades:**
/// - Inicio de sesión con email y contraseña
/// - Navegación a registro
/// - Navegación a recuperación de contraseña
/// - Manejo de estados de carga y errores mediante BLoC
/// 
/// Widget que muestra la pantalla de login
class LoginScreen extends StatefulWidget {
  //Constructor de la clase LoginScreen
  const LoginScreen({super.key});

  //Método createState que crea el estado de la pantalla de login
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variables para los controladores de los campos de texto
  // Nos permiten obtener el valor que el usuario escribe
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Para mostrar/ocultar la contraseña
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Limpiamos los controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Escuchar cambios de estado para mostrar feedback
          if (state is AuthAuthenticated) {
            // Éxito: Mostrar mensaje y navegar a home
            CustomSnackBar.showSuccess(
              context,
              message: AppStrings.loginSuccess,
              duration: const Duration(seconds: 2),
            );
            // Navegar a home
            context.go('/home');
          } else if (state is AuthError) {
            // Error: Mostrar mensaje
            CustomSnackBar.showError(
              context,
              message: state.message.replaceAll('Exception:', '').trim(),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo de la app
                  _buildAppLogo(),
                  const SizedBox(height: 40),

                  // Título
                  const Text(
                    AppStrings.welcome,
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
                    AppStrings.loginSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Campo de email
                  _buildEmailField(),
                  const SizedBox(height: 16),

                  // Campo de contraseña
                  _buildPasswordField(),
                  const SizedBox(height: 12),

                  // Botón "¿Olvidaste tu contraseña?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : () => context.push('/forgot-password'),
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de Iniciar Sesión
                  _buildLoginButton(context, isLoading),
                  const SizedBox(height: 24),

                  // Divisor "O"
                  _buildDivider(),
                  const SizedBox(height: 24),

                  // Link de registro
                  _buildRegisterLink(context, isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Logo de la app
  /// 
  Widget _buildAppLogo() {
    //Container para el logo de la app
    return Container(

      //Height para el logo de la app
      //100 para que el logo se coloque a 100 unidades de alto
      height: 100,
      //Width para el logo de la app
      //100 para que el logo se coloque a 100 unidades de ancho
      width: 100,
      //Decoration para el logo de la app
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.attach_money_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  /// Campo de correo electrónico
  Widget _buildEmailField() {
    //TextField para el campo de correo electrónico
    return TextField(
      //Controller para el campo de correo electrónico
      controller: _emailController,
      //keyboardType para el tipo de teclado
      //TextInputType.emailAddress para que el teclado sea de correo electrónico
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        //labelText para el texto del campo de correo electrónico
        labelText: AppStrings.email,
        //prefixIcon para el icono del campo de correo electrónico
        prefixIcon: const Icon(Icons.email_outlined),
        //border para el borde del campo de correo electrónico
        //OutlineInputBorder para el borde del campo de correo electrónico
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        //enabledBorder para el borde del campo de correo electrónico cuando está habilitado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.indicatorInactive),
        ),
        //focusedBorder para el borde del campo de correo electrónico cuando está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  /// Campo de contraseña
  Widget _buildPasswordField() {
    return TextField(
      //Controller para el campo de contraseña
      controller: _passwordController,
      //obscureText para que el texto se muestre como contraseña
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        //labelText para el texto del campo de contraseña
        labelText: AppStrings.password,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          //icon para el icono del campo de contraseña
          icon: Icon(
            //Icon para el icono del campo de contraseña
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          //onPressed para el botón de mostrar/ocultar la contraseña
          onPressed: () {
            //setState para actualizar el estado de la contraseña
            setState(() {              
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        //border para el borde del campo de contraseña
        border: OutlineInputBorder(
          //borderRadius para el borde del campo de contraseña
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
      ),
    );
  }

  /// Botón de Iniciar Sesión
  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleLogin(context),
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
                AppStrings.login,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Maneja el inicio de sesión
  void _handleLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseCompleteAllFields),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.emailInvalid),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Enviar evento al BLoC
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: email,
            password: password,
          ),
        );
  }

  /// Divisor con texto "O"
  Widget _buildDivider() {
    //Row para el divisor con texto "O"
    return const Row(
      children: [
        //Expanded para el divisor con texto "O" 
        //Divider para el divisor con texto "O"
        //color para el color del divisor
        //AppColors.indicatorInactive para el color del divisor
        Expanded(child: Divider(color: AppColors.indicatorInactive)),
        //Padding para el texto "O"
        //EdgeInsets.symmetric para el padding horizontal
        //16 para que el padding sea de 16 unidades de distancia
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.or,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: AppColors.indicatorInactive)),
      ],
    );
  }

  /// Link para registro
  Widget _buildRegisterLink(BuildContext context, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          AppStrings.noAccount,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.push('/register'),
          child: const Text(
            AppStrings.register,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

