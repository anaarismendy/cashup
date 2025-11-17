import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashup/data/models/user_model.dart';
import 'package:cashup/data/models/profile_model.dart';
import 'package:cashup/domain/entities/user_entity.dart';

/// **SUPABASE_AUTH_DATASOURCE**
/// 
/// Clase que maneja TODAS las interacciones de autenticación con Supabase.
/// 

class SupabaseAuthDataSource {
  //
  final SupabaseClient _supabaseClient;

  SupabaseAuthDataSource(this._supabaseClient);

  /// Registra un nuevo usuario
  /// 
  /// **Flujo CORREGIDO (usando trigger de Supabase):**
  /// 1. Crea el usuario en Supabase Auth CON metadata
  /// 2. El trigger automáticamente crea el perfil con first_name y last_name separados
  /// 3. Obtiene y retorna el perfil creado por el trigger
  
  // Registra un nuevo usuario
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  }) async {
    try {
      // 1. Registrar en Supabase Auth CON userMetadata
      // El trigger lee estos datos de raw_user_meta_data
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          // Datos que el trigger leerá automáticamente
          'first_name': firstName,  // ← Separado
          'last_name': lastName,     // ← Separado
          'birth_date': birthDate.toIso8601String().split('T')[0], // 'YYYY-MM-DD'
          'gender': gender ?? 'prefiero_no_decir',
        },
      );
      print('Usuario creado: ${response}');
      // Si no se crea el usuario, se lanza una excepción
      if (response.user == null) {
        throw Exception('Error al crear usuario');
      }

      // Se obtiene el usuario creado
      final user = response.user!;

      // // Se retorna el usuario creado
      return UserModel(
        id: user.id,
        email: email,
        profile: ProfileEntity(
          id: user.id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          birthDate: birthDate,
          gender: gender,
        ),
      );
    } on AuthException catch (e) {
      // Errores específicos de Supabase Auth
      throw _handleAuthException(e);
    } on PostgrestException catch (e) {
      // Errores de la base de datos (incluidos los del trigger)
      if (e.message.contains('al menos 15 años')) {
        throw Exception('Debes tener al menos 15 años para usar esta aplicación');
      }
      throw Exception('Error de base de datos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al registrar: $e');
    }
  }

  /// Inicia sesión
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Credenciales incorrectas');
      }

      final user = response.user!;

      // Obtener el perfil del usuario
      final profileResponse = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // ← Cambiado a maybeSingle()

      // Verificar que el perfil existe
      if (profileResponse == null) {
        throw Exception('Perfil de usuario no encontrado');
      }

      final profile = ProfileModel.fromJson(profileResponse);

      return UserModel(
        id: user.id,
        email: user.email!,
        profile: profile,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Obtiene el usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) return null;

      // Obtener el perfil
      final profileResponse = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // ← Cambiado a maybeSingle()

      // Si no hay perfil, retornar null
      if (profileResponse == null) return null;

      final profile = ProfileModel.fromJson(profileResponse);

      return UserModel(
        id: user.id,
        email: user.email!,
        profile: profile,
      );
    } catch (e) {
      // Si hay error, probablemente no hay sesión
      return null;
    }
  }

  /// Envía email para recuperar contraseña
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  /// Actualiza la contraseña
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al actualizar contraseña: $e');
    }
  }

  /// Stream de cambios de autenticación
  /// 
  /// **¿Cómo funciona?**
  /// Supabase emite eventos cuando el estado de auth cambia
  /// (login, logout, token refresh, etc.)
  Stream<UserModel?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((state) async {
      final user = state.session?.user;
      
      if (user == null) return null;

      try {
        // Obtener perfil actualizado
        final profileResponse = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        final profile = ProfileModel.fromJson(profileResponse);

        return UserModel(
          id: user.id,
          email: user.email!,
          profile: profile,
        );
      } catch (e) {
        return null;
      }
    });
  }

  /// Maneja excepciones de Supabase Auth y las convierte en mensajes legibles
  Exception _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('already registered')) {
          return Exception('Este email ya está registrado');
        }
        return Exception('Datos inválidos');
      case '422':
        return Exception('La contraseña debe tener al menos 6 caracteres');
      default:
        return Exception(e.message);
    }
  }
}

