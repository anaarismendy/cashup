import 'package:cashup/domain/repositories/auth_repository.dart';

/// **RESET_PASSWORD (Caso de Uso)**
/// 
/// Envía un email para recuperar la contraseña.
class ResetPassword {
  final AuthRepository _repository;

  ResetPassword(this._repository);

  Future<void> call({required String email}) async {
    await _repository.resetPassword(email: email);
  }
}

