import 'package:cashup/domain/entities/user_entity.dart';

/// **AUTH_REPOSITORY (Contrato de Autenticación)**
/// 
/// Define QUÉ operaciones de autenticación existen, pero NO cómo se implementan.
/// 
abstract class AuthRepository {
  /// Registra un nuevo usuario
  /// 
  /// **Parámetros:**
  /// - email: Correo electrónico
  /// - password: Contraseña
  /// - firstName: Nombre
  /// - lastName: Apellido
  /// - birthDate: Fecha de nacimiento
  /// - gender: Género (opcional)
  /// 
  /// **Retorna:** UserEntity con los datos del usuario creado
  /// 
  /// **Lanza excepciones si:**
  /// - El email ya está registrado
  /// - La contraseña es débil
  /// - Hay error de conexión
  Future<UserEntity> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  });

  /// Inicia sesión con email y contraseña
  /// 
  /// **Retorna:** UserEntity con los datos del usuario
  /// 
  /// **Lanza excepciones si:**
  /// - Las credenciales son incorrectas
  /// - El usuario no existe
  /// - Hay error de conexión
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual
  Future<void> logout();

  /// Obtiene el usuario actualmente autenticado
  /// 
  /// **Retorna:** 
  /// - UserEntity si hay sesión activa
  /// - null si no hay sesión
  Future<UserEntity?> getCurrentUser();

  /// Envía un email para recuperar la contraseña
  /// 
  /// **Parámetros:**
  /// - email: Correo al que se enviará el link de recuperación
  Future<void> resetPassword({required String email});

  /// Actualiza la contraseña del usuario
  /// 
  /// **Parámetros:**
  /// - newPassword: Nueva contraseña
  /// 
  /// **Requiere:** Sesión activa
  Future<void> updatePassword({required String newPassword});

  /// Stream que notifica cambios en el estado de autenticación
  /// 
  /// **¿Por qué Stream?**
  /// Permite escuchar en tiempo real si el usuario se autentica/desautentica
  /// 
  /// **Emite:**
  /// - UserEntity cuando hay sesión activa
  /// - null cuando no hay sesión
  Stream<UserEntity?> get authStateChanges;
}

