import 'package:cashup/domain/entities/user_entity.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';

/// **LOGIN_USER (Caso de Uso)**
/// 
/// Encapsula la lógica de inicio de sesión.
class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}

