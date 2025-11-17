import 'package:cashup/domain/entities/user_entity.dart';
import 'package:cashup/domain/repositories/auth_repository.dart';

/// **REGISTER_USER (Caso de Uso)**
/// 
/// Encapsula la lógica de registro de un nuevo usuario.
/// 

class RegisterUser {
  //Repositorio de autenticación
  final AuthRepository _repository;

  //Constructor de la clase RegisterUser
  RegisterUser(this._repository);

  //Ejecuta el registro
  Future<UserEntity> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  }) async {
    
    
    return await _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      gender: gender,
    );
  }
}

