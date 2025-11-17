import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/core/routes/app_router.dart';
import 'package:cashup/domain/usecases/onboarding/check_onboarding_status.dart';
import 'package:cashup/domain/usecases/auth/get_current_user.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';

/// **CashUp - Aplicación de Gestión de Finanzas Personales**
///
/// **Arquitectura:** Clean Architecture + SOLID Principles
/// **Estado:** BLoC Pattern
/// **Navegación:** GoRouter
/// **Backend:** Supabase (PostgreSQL + Auth + RPC)
///
/// **Flujo de Inicialización:**
/// 1. Configuración de Flutter bindings
/// 2. Carga de variables de entorno (.env)
/// 3. Inicialización de Supabase
/// 4. Configuración de dependencias (GetIt)
/// 5. Inicialización de localización
/// 6. Verificación de sesión activa
/// 7. Inicio de la aplicación

void main() async {
  // ============================================
  // PASO 1: Inicialización de Flutter Bindings
  // ============================================
  //
  // Necesario cuando se usa código asíncrono (await) antes de runApp()
  // Asegura que el motor de Flutter esté listo antes de ejecutar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // PASO 2: Configuración de Orientación
  // ============================================
  //
  // Bloquea la app en modo portrait (vertical)
  // Las apps financieras funcionan mejor en orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ============================================
  // PASO 3: Carga de Variables de Entorno
  // ============================================
  //
  // Carga las credenciales de Supabase desde el archivo .env
  // Esto mantiene las credenciales seguras y fuera del código fuente
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Si no se encuentra el archivo .env, mostrar error claro
    debugPrint('❌ Error: No se encontró el archivo .env');
    debugPrint('📝 Por favor, crea un archivo .env basado en .env.example');
    debugPrint('💡 Copia .env.example a .env y completa las credenciales');
    rethrow;
  }

  // Validar que las variables de entorno estén configuradas
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      '❌ Error: Las variables SUPABASE_URL y SUPABASE_ANON_KEY deben estar configuradas en .env',
    );
  }

  // ============================================
  // PASO 4: Inicialización de Supabase
  // ============================================
  //
  // Configura la conexión con Supabase usando las credenciales del .env
  // Supabase proporciona: Autenticación, Base de Datos, Storage, RPC
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('✅ Supabase inicializado correctamente');
  } catch (e) {
    debugPrint('❌ Error al inicializar Supabase: $e');
    rethrow;
  }

  // ============================================
  // PASO 5: Inicialización de Dependencias
  // ============================================
  //
  // Registra todas las dependencias en GetIt (Service Locator)
  // Esto incluye: Repositorios, Use Cases, BLoCs, Data Sources
  try {
    await initializeDependencies();
    debugPrint('✅ Dependencias inicializadas correctamente');
  } catch (e) {
    debugPrint('❌ Error al inicializar dependencias: $e');
    rethrow;
  }

  // ============================================
  // PASO 6: Inicialización de Localización
  // ============================================
  //
  // Carga los datos de formato de fecha para el locale español
  // Necesario para usar DateFormat con locales específicos
  try {
    await initializeDateFormatting('es', null);
    debugPrint('✅ Localización inicializada correctamente');
  } catch (e) {
    debugPrint('⚠️ Advertencia: Error al inicializar localización: $e');
    // No es crítico, continuamos sin localización
  }

  // ============================================
  // PASO 7: Verificación de Sesión Activa
  // ============================================
  //
  // Inicializa AuthBloc para verificar si hay una sesión activa
  // Esto asegura que el usuario se cargue antes de que la app inicie
  // El AuthBloc se crea como lazy singleton y verifica la sesión en su constructor
  try {
    sl<AuthBloc>();
    debugPrint('✅ Verificación de sesión completada');
  } catch (e) {
    debugPrint('❌ Error al verificar sesión: $e');
    rethrow;
  }

  // ============================================
  // PASO 8: Inicio de la Aplicación
  // ============================================
  //
  // Todos los pasos anteriores se completaron exitosamente
  // Ahora podemos iniciar la aplicación Flutter
  debugPrint('🚀 Iniciando CashUp...');
  runApp(const CashUpApp());
}

/// **CashUpApp - Widget Raíz de la Aplicación**
///
/// **Responsabilidades:**
/// - Configurar el tema global de la aplicación
/// - Proporcionar el router (GoRouter) a toda la app
/// - Configurar localizaciones e internacionalización
/// - Establecer opciones globales de Material Design
class CashUpApp extends StatelessWidget {
  const CashUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear instancia del router con los use cases necesarios
    // para verificar el estado del onboarding y la sesión activa
    final appRouter = AppRouter(
      sl<CheckOnboardingStatus>(),
      sl<GetCurrentUser>(),
    );

    return MaterialApp.router(
      // ============================================
      // Configuración Básica
      // ============================================
      title: 'CashUp',
      debugShowCheckedModeBanner: false, // Oculta el banner "DEBUG"

      // ============================================
      // Localizaciones e Internacionalización
      // ============================================
      //
      // Necesario para que DatePickerDialog y otros widgets de Material
      // funcionen correctamente en español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español (principal)
        Locale('en', 'US'), // Inglés (fallback)
      ],
      locale: const Locale('es', 'ES'),

      // ============================================
      // Tema de la Aplicación
      // ============================================
      //
      // Define los colores y estilos globales usando Material Design 3
      // Cualquier widget puede acceder a estos valores con Theme.of(context)
      theme: ThemeData(
        // Esquema de colores basado en Material 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C9A7), // Verde turquesa (color principal)
          primary: const Color(0xFF00C9A7),
          secondary: const Color(0xFF1E88E5), // Azul (color secundario)
        ),

        // Tipografía
        fontFamily: 'Roboto', // Fuente por defecto

        // Usa Material 3 (el nuevo sistema de diseño de Google)
        useMaterial3: true,

        // Estilo de los botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0, // Sin sombra
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Estilo de los campos de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ============================================
      // Configuración del Router
      // ============================================
      //
      // Le dice a MaterialApp que use GoRouter en lugar del Navigator tradicional
      // GoRouter proporciona navegación declarativa, deep linking y protección de rutas
      routerConfig: appRouter.router,
    );
  }
}

