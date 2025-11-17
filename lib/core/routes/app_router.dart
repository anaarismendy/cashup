import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/domain/usecases/onboarding/check_onboarding_status.dart';
import 'package:cashup/domain/usecases/auth/get_current_user.dart';
import 'package:cashup/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';
import 'package:cashup/presentation/blocs/home/home_bloc.dart';
import 'package:cashup/presentation/screens/login_screen.dart';
import 'package:cashup/presentation/screens/onboarding_screen.dart';
import 'package:cashup/presentation/screens/register_screen.dart';
import 'package:cashup/presentation/screens/forgot_password_screen.dart';
import 'package:cashup/presentation/screens/home_screen.dart';
import 'package:cashup/presentation/screens/transaction_detail_screen.dart';
import 'package:cashup/presentation/screens/statistics_screen.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_bloc.dart';

/// **APP_ROUTER (Configuración de Navegación)**
/// 
/// **¿Qué es GoRouter?**
/// Es el sistema de navegación oficial de Flutter que permite:
/// 1. Navegación declarativa (defines todas las rutas en un lugar)
/// 2. Deep linking (abrir la app en una pantalla específica desde un link)
/// 3. Navegación con paths (ej: /login, /home/profile)
/// 4. Redirecciones condicionales
/// 
/// **Flujo de navegación en nuestra app:**
/// 1. App inicia → Verifica si hay sesión activa
/// 2. Si hay sesión → va a /home
/// 3. Si NO hay sesión → Verifica si ya vio onboarding
/// 4. Si NO lo vio → va a /onboarding
/// 5. Si YA lo vio → va a /login
/// 6. Después del login → va a /home
class AppRouter {
  // Instancia del use case para verificar el estado del onboarding
  final CheckOnboardingStatus _checkOnboardingStatus;
  // Instancia del use case para verificar sesión activa
  final GetCurrentUser _getCurrentUser;

  AppRouter(this._checkOnboardingStatus, this._getCurrentUser);

  /// Configuración del router
  /// 
  /// **late:** Indica que se inicializará después, pero antes de usarse
  late final GoRouter router = GoRouter(
    // Ruta inicial (la primera que se muestra)
    initialLocation: '/',

    // **redirect:** Se ejecuta ANTES de cada navegación
    // Aquí manejamos la lógica de "¿A dónde debe ir el usuario?"
    redirect: (context, state) async {
      // Verificar si hay sesión activa
      final currentUser = await _getCurrentUser();
      final isAuthenticated = currentUser != null;

      // Proteger rutas autenticadas
      if (state.matchedLocation == '/home') {
        if (!isAuthenticated) {
          // Si intenta acceder a /home sin sesión, redirigir al login
          return '/login';
        }
        return null; // Permitir acceso
      }

      // Proteger rutas de autenticación (redirigir a home si ya está autenticado)
      if (state.matchedLocation == '/login' || 
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password') {
        if (isAuthenticated) {
          // Si ya está autenticado, redirigir a home
          return '/home';
        }
        return null; // Permitir acceso
      }

      // Solo aplicamos la lógica de redirección en la ruta raíz
      if (state.matchedLocation == '/') {
        // Si hay sesión activa, ir directamente a home
        if (isAuthenticated) {
          return '/home';
        }

        // Si no hay sesión, verificar onboarding
        final hasSeenOnboarding = await _checkOnboardingStatus();

        if (hasSeenOnboarding) {
          // Si ya lo vio, va al login
          return '/login';
        } else {
          // Si no lo ha visto, va al onboarding
          return '/onboarding';
        }
      }

      // Si no es ninguna de las rutas anteriores, no redirigimos
      return null;
    },

    /// **routes:** Lista de todas las rutas de la app
    routes: [
      /// Ruta raíz (/)
      /// Es un placeholder, siempre redirigirá a /onboarding o /login
      GoRoute(
        path: '/',
        builder: (context, state) => const SizedBox.shrink(),
      ),

      /// Ruta del Onboarding (/onboarding)
      /// 
      /// **BlocProvider:** Proveemos el OnboardingBloc a toda la pantalla
      /// El BLoC se crea aquí y se destruye cuando salimos de la pantalla
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider(
            // Obtenemos el bloc desde GetIt
            create: (context) => sl<OnboardingBloc>(),
            child: const OnboardingScreen(),
          ),
        ),
      ),

      /// Ruta del Login (/login)
      /// 
      /// **BlocProvider:** Provee el AuthBloc a la pantalla
      /// El mismo AuthBloc se comparte entre login y registro
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        ),
      ),

      /// Ruta del Registro (/register)
      /// 
      /// **BlocProvider.value:** Usamos el mismo AuthBloc singleton
      /// para mantener el estado de auth consistente en toda la app
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const RegisterScreen(),
          ),
        ),
      ),

      /// Ruta de Recuperación de Contraseña (/forgot-password)
      /// 
      /// **BlocProvider.value:** Usamos el mismo AuthBloc singleton
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      ),

      /// Ruta de Home (/home)
      /// 
      /// Pantalla principal tras autenticación exitosa
      /// **MultiBlocProvider:** Provee tanto AuthBloc como HomeBloc
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthBloc>()),
              BlocProvider(create: (context) => sl<HomeBloc>()),
            ],
            child: const HomeScreen(),
          ),
        ),
      ),

      /// Ruta de Detalle de Transacción (/transaction/:id)
      /// 
      /// Muestra los detalles de una transacción y permite editarla o eliminarla
      GoRoute(
        path: '/transaction/:id',
        pageBuilder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: TransactionDetailScreen(transactionId: transactionId),
          );
        },
      ),

      /// Ruta de Estadísticas (/statistics)
      /// 
      /// Muestra estadísticas financieras con gráficas y filtros
      GoRoute(
        path: '/statistics',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => sl<StatisticsBloc>(),
            child: const StatisticsScreen(),
          ),
        ),
      ),

      // ========== RUTAS FUTURAS ==========
      // Aquí agregarás más rutas cuando las implementes:
    ],

    /// **errorBuilder:** Pantalla que se muestra si hay un error de navegación
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// **MÉTODOS DE NAVEGACIÓN CON GoRouter:**
/// 
/// 1. **context.go('/login'):** 
///    - Reemplaza la pantalla actual
///    - No se puede regresar con el botón atrás
///    - Ideal para cambios de flujo (onboarding → login)
/// 
/// 2. **context.push('/profile'):**
///    - Apila una nueva pantalla encima
///    - Se puede regresar con el botón atrás
///    - Ideal para detalles o formularios
/// 
/// 3. **context.pop():**
///    - Regresa a la pantalla anterior
///    - Equivalente a Navigator.pop()
/// 
/// 4. **context.replace('/home'):**
///    - Reemplaza la pantalla actual sin animación
/// 
/// **Ejemplo en código:**
/// ```dart
/// // Navegar al login
/// context.go('/login');
/// 
/// // Abrir perfil (con botón atrás)
/// context.push('/home/profile');
/// 
/// // Regresar
/// context.pop();
/// ```

