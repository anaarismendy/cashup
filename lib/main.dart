import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/core/routes/app_router.dart';
import 'package:cashup/domain/usecases/onboarding/check_onboarding_status.dart';

/// **MAIN.DART - Punto de entrada de la aplicación**
///
/// **Flujo de inicio:**
/// 1. main() se ejecuta
/// 2. Se inicializan las dependencias (GetIt)
/// 3. Se crea la app con el router configurado
/// 4. El router decide a qué pantalla ir (onboarding o login)

void main() async {
  /// **WidgetsFlutterBinding.ensureInitialized()**
  ///
  /// **¿Por qué es necesario?**
  /// Cuando usas código asíncrono (await) en main() ANTES de runApp(),
  /// necesitas inicializar los bindings de Flutter manualmente.
  ///
  /// Esto asegura que el motor de Flutter esté listo antes de ejecutar
  /// código nativo (como SharedPreferences).
  WidgetsFlutterBinding.ensureInitialized();

  /// **Configuración de orientación**
  /// Bloquea la app en modo portrait (vertical)
  ///
  /// **¿Por qué?**
  /// Las apps financieras suelen funcionar mejor en vertical.
  /// Si quieres permitir horizontal, comenta estas líneas.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url:
        'https://brbutrafgcxtjcliindg.supabase.co', // Ej: https://xxxxxxxxxxx.supabase.co
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJyYnV0cmFmZ2N4dGpjbGlpbmRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxNDAyODgsImV4cCI6MjA3ODcxNjI4OH0.lNdhAxcRMYdEAVlQWWWjvHTXpU3Xc_r4ILGBGXmUi5I', // La clave pública
  );

  /// **Inicialización de dependencias**
  ///
  /// Aquí se registran TODAS las dependencias en GetIt:
  /// - SharedPreferences
  /// - LocalStorage
  /// - Repositorios
  /// - Use Cases
  /// - BLoCs
  ///
  /// **¿Por qué aquí?**
  /// Porque necesitamos que todo esté listo ANTES de que la app arranque.
  await initializeDependencies();

  // 🔄 RESETEAR ONBOARDING (Solo para testing - ELIMINAR después)
  // Descomenta estas líneas UNA VEZ para ver el onboarding de nuevo:
  // final localStorage = sl<local_storage.LocalStorage>();
  // await localStorage.resetOnboarding();
  // print('✅ Onboarding reseteado - Elimina estas líneas después');

  /// **Iniciar la aplicación**
  runApp(const MyApp());
}

/// **MyApp - Widget raíz de la aplicación**
///
/// **Responsabilidades:**
/// 1. Configurar el tema de la app
/// 2. Proporcionar el router a toda la app
/// 3. Configurar opciones globales
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Creamos el router y le pasamos el use case
    // para que pueda verificar el estado del onboarding
    final appRouter = AppRouter(sl<CheckOnboardingStatus>());

    return MaterialApp.router(
      /// **Configuración básica**
      title: 'CashUp',
      debugShowCheckedModeBanner: false,
      // Quita el banner de "DEBUG"

      /// **Tema de la app**
      ///
      /// **ThemeData:** Define los colores y estilos globales
      /// Cualquier widget puede acceder a estos valores con:
      /// Theme.of(context).primaryColor
      theme: ThemeData(
        // Esquema de colores basado en Material 3
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C9A7), // Verde turquesa
          primary: const Color(0xFF00C9A7),
          secondary: const Color(0xFF1E88E5),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      /// **Configuración del Router**
      ///
      /// **routerConfig:** Le dice a MaterialApp que use GoRouter
      /// en lugar del Navigator tradicional
      routerConfig: appRouter.router,
    );
  }
}

/// **RESUMEN DE LA ARQUITECTURA:**
/// 
/// ```
/// ┌─────────────────────────────────────────────────────────────┐
/// │                      PRESENTATION LAYER                      │
/// │  ┌──────────┐    ┌──────────┐    ┌───────────────────────┐ │
/// │  │  Screens │ ←→ │   BLoC   │ ←→ │ Events/States/Widgets │ │
/// │  └──────────┘    └──────────┘    └───────────────────────┘ │
/// └───────────────────────────┬─────────────────────────────────┘
///                             │
///                             ↓
/// ┌─────────────────────────────────────────────────────────────┐
/// │                       DOMAIN LAYER                           │
/// │  ┌────────────────┐         ┌──────────────────────────┐    │
/// │  │  Repositories  │  ←────  │      Use Cases           │    │
/// │  │ (Interfaces)   │         │ (Business Logic)         │    │
/// │  └────────────────┘         └──────────────────────────┘    │
/// └───────────────────────────┬─────────────────────────────────┘
///                             │
///                             ↓
/// ┌─────────────────────────────────────────────────────────────┐
/// │                        DATA LAYER                            │
/// │  ┌────────────────┐         ┌──────────────────────────┐    │
/// │  │  Repositories  │  ←────  │     Data Sources         │    │
/// │  │(Implementation)│         │ (Local/Remote Storage)   │    │
/// │  └────────────────┘         └──────────────────────────┘    │
/// └─────────────────────────────────────────────────────────────┘
///
///                     ↕ GetIt (Dependency Injection) ↕
///
/// ```
/// 
/// **Flujo de datos:**
/// 1. UI envía un Evento al BLoC
/// 2. BLoC llama a un Use Case
/// 3. Use Case llama al Repository
/// 4. Repository llama al Data Source
/// 5. Data Source obtiene/guarda datos
/// 6. Los datos regresan por el mismo camino
/// 7. BLoC emite un nuevo Estado
/// 8. UI se reconstruye con el nuevo Estado
///
/// **Ventajas de esta arquitectura:**
/// ✅ Testeable (cada capa se prueba independientemente)
/// ✅ Mantenible (cambios en una capa no afectan otras)
/// ✅ Escalable (fácil agregar nuevas features)
/// ✅ Separa responsabilidades (SOLID)
/// ✅ Código reutilizable
