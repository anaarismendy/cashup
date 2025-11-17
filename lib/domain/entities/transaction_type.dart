/// **TRANSACTION_TYPE (Tipo de Transacción)**
/// 
/// Enum que representa el tipo de transacción en el sistema.
/// Corresponde al enum `transaction_type` de Supabase.
enum TransactionType {
  /// Ingreso - Dinero que entra
  income('income'),
  
  /// Gasto - Dinero que sale
  expense('expense');

  final String value;

  const TransactionType(this.value);

  /// Convierte un string a TransactionType
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.expense,
    );
  }

  /// Convierte TransactionType a string para Supabase
  String toJson() => value;
}

