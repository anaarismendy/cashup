import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/domain/entities/category_entity.dart';

/// **TRANSACTION_ENTITY (Entidad de Transacción)**
/// 
/// Representa una transacción financiera en el sistema.
/// Esta es la entidad de DOMINIO (negocio puro), sin dependencias de Supabase.
/// 
/// **Características:**
/// - Puede ser un ingreso o un gasto
/// - Está asociada a una categoría (opcional)
/// - Tiene un monto, título y descripción
/// - Incluye fecha de transacción
class TransactionEntity extends Equatable {
  /// ID único de la transacción (UUID)
  final String id;
  
  /// ID del usuario propietario
  final String userId;
  
  /// ID de la categoría asociada (opcional)
  /// 
  /// **¿Por qué existe este campo?**
  /// - Es la foreign key que se almacena en la base de datos
  /// - Se usa cuando CREAMOS o ACTUALIZAMOS una transacción
  /// - Es lo mínimo necesario para establecer la relación
  /// 
  /// **Ejemplo:** "abc-123-def" (UUID de la categoría)
  final String? categoryId;
  
  /// Categoría completa asociada (opcional, para evitar joins)
  /// 
  /// **¿Por qué existe este campo?**
  /// - Contiene el objeto completo de la categoría (nombre, icono, color, etc.)
  /// - Se obtiene cuando hacemos un JOIN con la tabla `categories` en Supabase
  /// - Evita el problema N+1: no necesitamos hacer consultas adicionales
  ///   para obtener los datos de la categoría de cada transacción
  /// 
  /// **¿Cuándo se usa?**
  /// - Cuando LEEMOS transacciones y queremos mostrar el icono/color de la categoría
  /// - En la UI para mostrar información visual (ej: TransactionCard)
  /// 
  /// **¿Cuándo NO se usa?**
  /// - Al crear una transacción (solo necesitamos el categoryId)
  /// - Cuando no necesitamos los detalles de la categoría
  /// 
  /// **Ejemplo de uso:**
  /// ```dart
  /// // En TransactionCard, usamos category para obtener el icono:
  /// transaction.category?.icon  // "🛒"
  /// transaction.category?.color // "#6C5CE7"
  /// ```
  final CategoryEntity? category;
  
  /// Título de la transacción
  final String title;
  
  /// Descripción adicional (opcional)
  final String? description;
  
  /// Monto de la transacción (siempre positivo)
  final double amount;
  
  /// Tipo de transacción (income o expense)
  final TransactionType type;
  
  /// Fecha de la transacción
  final DateTime transactionDate;
  
  /// Fecha de creación
  final DateTime? createdAt;
  
  /// Última actualización
  final DateTime? updatedAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.categoryId,
    this.category,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Monto con signo según el tipo
  /// - Ingresos: positivo (+)
  /// - Gastos: negativo (-)
  double get signedAmount {
    return type == TransactionType.income ? amount : -amount;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        category,
        title,
        description,
        amount,
        type,
        transactionDate,
        createdAt,
        updatedAt,
      ];

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    CategoryEntity? category,
    String? title,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

