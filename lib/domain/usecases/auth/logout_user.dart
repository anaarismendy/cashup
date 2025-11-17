import 'package:cashup/domain/repositories/auth_repository.dart';

/// **LOGOUT_USER (Caso de Uso)**
/// 
/// Cierra la sesión del usuario actual.
class LogoutUser {
  final AuthRepository _repository;

  LogoutUser(this._repository);

  Future<void> call() async {
    await _repository.logout();
  }
}

