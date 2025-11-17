import 'package:cashup/domain/entities/user_entity.dart';
import 'package:cashup/data/models/profile_model.dart';

/// **USER_MODEL (Modelo de Usuario)**
/// 

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    //profile es opcional porque puede no estar creado aún
    super.profile,
  });

  //Crea un UserModel desde JSON de Supabase Auth
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': profile != null 
          ? (profile as ProfileModel).toJson() 
          : null,
    };
  }

  /// Convierte desde la entidad de dominio al modelo
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      profile: entity.profile != null
          ? ProfileModel.fromEntity(entity.profile!)
          : null,
    );
  }

  /// Convierte el modelo a entidad de dominio
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      profile: profile,
    );
  }
}

