import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/domain/usecases/auth/register_user.dart';
import 'package:cashup/domain/usecases/auth/login_user.dart';
import 'package:cashup/domain/usecases/auth/logout_user.dart';
import 'package:cashup/domain/usecases/auth/get_current_user.dart';
import 'package:cashup/domain/usecases/auth/reset_password.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';
import 'package:cashup/presentation/blocs/auth/auth_event.dart';
import 'package:cashup/presentation/blocs/auth/auth_state.dart';

/// **AUTH_BLOC**
/// 
/// Maneja toda la lógica de autenticación de la aplicación.
/// 
/// **Responsabilidades:**
/// - Procesar eventos de auth (login, register, logout)
/// - Emitir estados para actualizar la UI
/// - Escuchar cambios en el estado de autenticación de Supabase
/// 
/// **Flujo típico:**
/// 1. UI envía evento (ej: AuthLoginRequested)
/// 2. BLoC emite AuthLoading
/// 3. BLoC llama al use case correspondiente
/// 4. Use case retorna resultado o error
/// 5. BLoC emite AuthAuthenticated o AuthError
/// 6. UI reacciona al nuevo estado
/// 
/// BLoC para manejar la autenticación de la aplicación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  //Casos de uso 
  final RegisterUser _registerUser; //Caso de uso para registrar un nuevo usuario
  final LoginUser _loginUser; //Caso de uso para iniciar sesión
  final LogoutUser _logoutUser; //Caso de uso para cerrar sesión
  final GetCurrentUser _getCurrentUser; //Caso de uso para obtener el usuario autenticado
  final ResetPassword _resetPassword; //Caso de uso para resetear la contraseña
  final AuthRepository _authRepository; //Repositorio de autenticación

  // Subscription al stream de cambios de auth para escuchar cambios en el estado de autenticación de Supabase
  StreamSubscription<dynamic>? _authStateSubscription;

  //Constructor de la clase AuthBloc
  AuthBloc({
    required RegisterUser registerUser,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required GetCurrentUser getCurrentUser,
    required ResetPassword resetPassword,
    required AuthRepository authRepository,
  })  : _registerUser = registerUser,
        _loginUser = loginUser,
        _logoutUser = logoutUser,
        _getCurrentUser = getCurrentUser,
        _resetPassword = resetPassword,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    // Registrar handlers de eventos
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Escuchar cambios en el estado de autenticación
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthStateChanged(isAuthenticated: user != null));
    });

    // Verificar automáticamente si hay sesión activa al inicializar
    add(const AuthCheckRequested());
  }

  /// Maneja el registro de un nuevo usuario
  Future<void> _onRegisterRequested(
    //Evento de registro de un nuevo usuario
    AuthRegisterRequested event,
    //Emisor de estados de autenticación
    Emitter<AuthState> emit,
  ) async {
    //Emite el estado de carga
    emit(const AuthLoading());

    try {
      //Llamamos al caso de uso para registrar un nuevo usuario
      final user = await _registerUser(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        birthDate: event.birthDate,
        gender: event.gender,
      );

      //Emite el estado de autenticación
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      //Emite el estado de error
      emit(AuthError(message: e.toString()));
      // Después de mostrar el error, volver a unauthenticated
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const AuthUnauthenticated());
    }
  }

  /// Maneja el inicio de sesión
  Future<void> _onLoginRequested(
    //Evento de inicio de sesión
    AuthLoginRequested event,
    //Emisor de estados de autenticación
    Emitter<AuthState> emit,
  ) async {
    //Emite el estado de carga
    emit(const AuthLoading());

    try {
      //Llamamos al caso de uso para iniciar sesión
      final user = await _loginUser(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const AuthUnauthenticated());
    }
  }

  /// Maneja el cierre de sesión
  Future<void> _onLogoutRequested(
    //Evento de cierre de sesión
    AuthLogoutRequested event,
    //Emisor de estados de autenticación
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _logoutUser();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Error al cerrar sesión'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const AuthUnauthenticated());
    }
  }

  /// Verifica si hay usuario autenticado (al iniciar la app)
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Maneja la solicitud de recuperación de contraseña
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _resetPassword(email: event.email);
      emit(AuthPasswordResetSent(email: event.email));
      // Después de mostrar confirmación, volver a unauthenticated
      await Future.delayed(const Duration(seconds: 3));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Error al enviar email de recuperación'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const AuthUnauthenticated());
    }
  }

  /// Maneja cambios en el estado de autenticación desde Supabase
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (!event.isAuthenticated) {
      emit(const AuthUnauthenticated());
    }
    // Si es authenticated, el usuario ya está en el estado desde el login/register
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

