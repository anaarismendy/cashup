import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/user_entity.dart';

/// **AUTH_STATE (Estados de Autenticación)**
/// 
/// Representa los diferentes estados en los que puede estar la autenticación.
/// 
/// Sealed class para que no se pueda instanciar, solo extendiendo la clase
sealed class AuthState extends Equatable {
  const AuthState();

  //Lista de propiedades que se deben comparar para determinar si el estado ha cambiado
  @override
  List<Object?> get props => [];
}

/// Estado inicial - No sabemos si hay usuario autenticado
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Cargando (login, registro, logout en progreso)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado exitosamente
class AuthAuthenticated extends AuthState {
  //Usuario autenticado
  final UserEntity user;

  //Constructor de la clase AuthAuthenticated
  const AuthAuthenticated({required this.user});

  //Lista de propiedades que se deben comparar para determinar si el estado ha cambiado
  @override
  List<Object?> get props => [user];
}

/// No hay usuario autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error durante autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Email de recuperación enviado exitosamente
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

