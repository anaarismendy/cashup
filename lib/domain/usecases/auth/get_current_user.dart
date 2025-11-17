import 'package:cashup/domain/entities/user_entity.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';

/// **GET_CURRENT_USER (Caso de Uso)**
/// 
/// Obtiene el usuario actualmente autenticado.
/// 
/// **¿Cuándo usarlo?**
/// - Al iniciar la app para verificar si hay sesión
/// - Cuando necesitas datos del usuario actual
class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}

