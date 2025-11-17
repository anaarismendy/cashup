import 'package:cashup/data/datasources/supabase_auth_datasource.dart';
import 'package:cashup/domain/entities/user_entity.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';

/// **AUTH_REPOSITORY_IMPL**
/// 
/// Implementación del repositorio de autenticación usando Supabase.
/// 
class AuthRepositoryImpl implements AuthRepository {
  //Data source de autenticación 
  final SupabaseAuthDataSource _dataSource;

  //Constructor de la clase AuthRepositoryImpl
  AuthRepositoryImpl(this._dataSource);

  @override
  //Registra un nuevo usuario
  Future<UserEntity> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  }) async {
    // Llama al data source y crea el usuario
    final userModel = await _dataSource.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      gender: gender,
    );

    // Se convierte el usuario a una entidad de dominio
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final userModel = await _dataSource.login(
      email: email,
      password: password,
    );

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await _dataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _dataSource.resetPassword(email: email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _dataSource.updatePassword(newPassword: newPassword);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    // Convierte el stream de modelos a stream de entidades
    return _dataSource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }
}

