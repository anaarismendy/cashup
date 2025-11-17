import 'package:equatable/equatable.dart';

/// **USER_ENTITY (Entidad de Usuario)**
/// 
/// Representa un usuario autenticado en el sistema.
/// Esta es la entidad de DOMINIO (negocio puro), sin dependencias de Supabase.
/// 
class UserEntity extends Equatable {
  /// ID único del usuario (UUID de Supabase Auth)
  final String id;
  
  /// Email del usuario
  final String email;
  
  /// Perfil asociado (opcional porque puede no estar creado aún)
  final ProfileEntity? profile;

  const UserEntity({
    required this.id,
    required this.email,
    this.profile,
  });

// Propiedades del objeto UserEntity
  @override
  List<Object?> get props => [id, email, profile];

  UserEntity copyWith({
    String? id,
    String? email,
    ProfileEntity? profile,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      profile: profile ?? this.profile,
    );
  }
}

/// **PROFILE_ENTITY (Entidad de Perfil)**
/// 
/// Representa el perfil del usuario con información adicional.
/// Corresponde a la tabla `profiles` de Supabase.
class ProfileEntity extends Equatable {
  /// ID del perfil (mismo que el ID del usuario)
  final String id;
  
  /// Email (redundante pero útil para queries)
  final String email;
  
  /// Nombre
  final String firstName;
  
  /// Apellido
  final String lastName;
  
  /// URL del avatar (opcional)
  final String? avatarUrl;
  
  /// Fecha de nacimiento
  final DateTime birthDate;
  
  /// Edad calculada automáticamente por trigger
  final int? age;
  
  /// Género (masculino, femenino, otro, prefiero_no_decir)
  final String? gender;
  
  /// Moneda preferida (default: COP)
  final String currency;
  
  /// Fecha de creación
  final DateTime? createdAt;
  
  /// Última actualización
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.birthDate,
    this.age,
    this.gender,
    this.currency = 'COP',
    this.createdAt,
    this.updatedAt,
  });

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        avatarUrl,
        birthDate,
        age,
        gender,
        currency,
        createdAt,
        updatedAt,
      ];

  ProfileEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    DateTime? birthDate,
    int? age,
    String? gender,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

