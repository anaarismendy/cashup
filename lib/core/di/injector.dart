import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Data Sources
import 'package:cashup/data/datasources/local_storage.dart' as local_storage;
import 'package:cashup/data/datasources/supabase_auth_datasource.dart';

// Repositories Implementations
import 'package:cashup/data/repositories/onboarding_repository_impl.dart';
import 'package:cashup/data/repositories/auth_repository_impl.dart';

// Domain Repositories
import 'package:cashup/domain/repositories/onboarding_repository.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';

// Onboarding Use Cases
import 'package:cashup/domain/usecases/onboarding/check_onboarding_status.dart';
import 'package:cashup/domain/usecases/onboarding/set_onboarding_as_seen.dart';

// Auth Use Cases
import 'package:cashup/domain/usecases/auth/register_user.dart';
import 'package:cashup/domain/usecases/auth/login_user.dart';
import 'package:cashup/domain/usecases/auth/logout_user.dart';
import 'package:cashup/domain/usecases/auth/get_current_user.dart';
import 'package:cashup/domain/usecases/auth/reset_password.dart';

// BLoCs
import 'package:cashup/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';

/// **INJECTOR (Configuración de GetIt)**
/// 
/// **¿Qué es GetIt?**
/// Es un Service Locator (contenedor de dependencias) que nos permite:
/// 1. Registrar todas las dependencias de la app en un solo lugar
/// 2. Obtener instancias cuando las necesitemos
/// 3. Gestionar el ciclo de vida de los objetos
/// 
/// **Tipos de registro:**
/// - **registerLazySingleton:** Crea UNA instancia la primera vez que se necesita
///   y la reutiliza siempre. Ideal para servicios que viven toda la app.
/// - **registerFactory:** Crea una NUEVA instancia cada vez que se solicita.
///   Ideal para BLoCs que tienen ciclo de vida corto.
/// 
/// **¿Por qué usar inyección de dependencias?**
/// 1. **Testeable:** Podemos inyectar mocks en los tests
/// 2. **Flexible:** Fácil cambiar implementaciones
/// 3. **Desacoplado:** Las clases no saben cómo se crean sus dependencias
/// 4. **Principio de Inversión de Dependencias (SOLID)**

// Instancia global de GetIt
// `sl` es una convención que significa "Service Locator"
final sl = GetIt.instance;

/// Inicializa todas las dependencias de la app
/// 
/// **¿Cuándo se llama?**
/// En el main.dart, ANTES de runApp()
/// 
/// **¿Por qué async?**
/// Porque SharedPreferences necesita inicializarse de forma asíncrona
Future<void> initializeDependencies() async {
  // ========== EXTERNAL DEPENDENCIES ==========
  // Dependencias de paquetes externos que necesitan inicialización

  /// SharedPreferences
  /// **Por qué registerLazySingleton?**
  /// Solo necesitamos UNA instancia de SharedPreferences en toda la app
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  /// Supabase Client
  /// Instancia global de Supabase (ya inicializada en main.dart)
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // ========== DATA SOURCES ==========
  // Clases que manejan el acceso a datos (storage, APIs, etc.)

  /// LocalStorage
  /// Depende de SharedPreferences, por eso lo obtenemos con sl()
  sl.registerLazySingleton<local_storage.LocalStorage>(
    () => local_storage.LocalStorage(sl()),
  );

  /// SupabaseAuthDataSource
  /// Maneja todas las operaciones de autenticación con Supabase
  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSource(sl()),
  );

  // ========== REPOSITORIES ==========
  // Implementaciones de los repositorios

  /// OnboardingRepository
  /// **Nota:** Registramos la interfaz (OnboardingRepository)
  /// pero retornamos la implementación (OnboardingRepositoryImpl)
  /// Esto permite que el código dependa de abstracciones, no de implementaciones
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );

  /// AuthRepository
  /// Repositorio de autenticación
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ========== USE CASES ==========
  // Casos de uso que encapsulan la lógica de negocio

  /// CheckOnboardingStatus
  /// Use case para verificar si ya se vio el onboarding
  sl.registerLazySingleton<CheckOnboardingStatus>(
    () => CheckOnboardingStatus(sl()),
  );

  /// MarkOnboardingAsSeen
  /// Use case para marcar el onboarding como visto
  sl.registerLazySingleton<SetOnboardingAsSeen>(
    () => SetOnboardingAsSeen(sl()),
  );

  // ========== AUTH USE CASES ==========
  
  /// RegisterUser
  /// Use case para registrar un nuevo usuario
  sl.registerLazySingleton<RegisterUser>(
    () => RegisterUser(sl()),
  );

  /// LoginUser
  /// Use case para iniciar sesión
  sl.registerLazySingleton<LoginUser>(
    () => LoginUser(sl()),
  );

  /// LogoutUser
  /// Use case para cerrar sesión
  sl.registerLazySingleton<LogoutUser>(
    () => LogoutUser(sl()),
  );

  /// GetCurrentUser
  /// Use case para obtener el usuario actual
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl()),
  );

  /// ResetPassword
  /// Use case para recuperar contraseña
  sl.registerLazySingleton<ResetPassword>(
    () => ResetPassword(sl()),
  );

  // ========== BLOCS ==========
  // BLoCs para manejar el estado de la UI

  /// OnboardingBloc
  /// **Por qué registerFactory?**
  /// Los BLoCs tienen ciclo de vida corto (viven mientras la pantalla está activa)
  /// Queremos una nueva instancia cada vez que navegamos a la pantalla
  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(sl()),
  );

  /// AuthBloc
  /// BLoC para manejar el estado de autenticación
  /// **registerLazySingleton porque?**
  /// Queremos mantener el estado de auth en toda la app
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      registerUser: sl(),
      loginUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
      resetPassword: sl(),
      authRepository: sl(),
    ),
  );
}

/// **CÓMO USAR GetIt EN TU CÓDIGO:**
/// 
/// 1. Para obtener una dependencia:
///    ```dart
///    final bloc = sl<OnboardingBloc>();
///    ```
/// 
/// 2. En un widget con BlocProvider:
///    ```dart
///    BlocProvider(
///      create: (context) => sl<OnboardingBloc>(),
///      child: OnboardingScreen(),
///    )
///    ```
/// 
/// 3. Para obtener un use case:
///    ```dart
///    final checkStatus = sl<CheckOnboardingStatus>();
///    final hasSeen = await checkStatus();
///    ```

