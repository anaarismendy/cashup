import 'package:equatable/equatable.dart';

/// **AUTH_EVENT (Eventos de Autenticación)**
/// 
/// Acciones que el usuario puede realizar relacionadas con autenticación.
/// 
/// Sealed class para que no se pueda instanciar, solo extendiendo la clase
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Usuario presiona "Registrarse"
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? gender;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.gender,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, birthDate, gender];
}

/// Usuario presiona "Iniciar Sesión"
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Usuario presiona "Cerrar Sesión"
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Verifica si hay usuario autenticado (al iniciar la app)
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Usuario solicita recuperar contraseña
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// El estado de auth cambió (desde el stream de Supabase)
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}

