import 'package:cashup/domain/entities/user_entity.dart';

/// **PROFILE_MODEL (Modelo de Perfil)**
/// 
/// Versión de ProfileEntity que maneja JSON de Supabase.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.avatarUrl,
    required super.birthDate,
    super.age,
    super.gender,
    super.currency = 'COP',
    super.createdAt,
    super.updatedAt,
  });

  
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: DateTime.parse(json['birth_date'] as String),
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      currency: json['currency'] as String? ?? 'COP',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON para enviar a Supabase
  /// 
  /// **Nota:** Usamos snake_case porque es el formato de Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'birth_date': birthDate.toIso8601String().split('T')[0], // Solo la fecha
      'age': age,
      'gender': gender,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convierte desde la entidad de dominio
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      avatarUrl: entity.avatarUrl,
      birthDate: entity.birthDate,
      age: entity.age,
      gender: entity.gender,
      currency: entity.currency,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte a entidad de dominio
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      birthDate: birthDate,
      age: age,
      gender: gender,
      currency: currency,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

