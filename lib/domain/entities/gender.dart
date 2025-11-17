/// **GENDER (Enum de Género)**
/// 
/// Define los valores permitidos para el género según la BD.
/// 
enum Gender {
  masculino('masculino', 'Masculino'),
  femenino('femenino', 'Femenino'),
  otro('otro', 'Otro'),
  prefieroNoDecir('prefiero_no_decir', 'Prefiero no decir');

  /// Valor en la base de datos
  final String value;
  
  /// Texto a mostrar en la UI
  final String displayName;

  const Gender(this.value, this.displayName);

  /// Convierte desde el valor de la BD al enum
  static Gender fromValue(String value) {
    return Gender.values.firstWhere(
      //firstWhere para encontrar el género que coincide con el valor
      (gender) => gender.value == value,
      //orElse para devolver el género por defecto
      orElse: () => Gender.prefieroNoDecir,
    );
  }
}

