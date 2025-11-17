import 'package:cashup/domain/entities/transaction_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/data/models/category_model.dart';

/// **TRANSACTION_MODEL (Modelo de Transacción)**
/// 
/// Modelo de datos que extiende TransactionEntity.
/// Se encarga de la conversión entre JSON (Supabase) y entidades de dominio.
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    super.categoryId,
    super.category,
    required super.title,
    super.description,
    required super.amount,
    required super.type,
    required super.transactionDate,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un TransactionModel desde JSON de Supabase
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromString(json['type'] as String),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type.toJson(),
      'transaction_date': transactionDate.toIso8601String().split('T')[0], // Solo fecha
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convierte desde la entidad de dominio al modelo
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      category: entity.category != null
          ? CategoryModel.fromEntity(entity.category!)
          : null,
      title: entity.title,
      description: entity.description,
      amount: entity.amount,
      type: entity.type,
      transactionDate: entity.transactionDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte el modelo a entidad de dominio
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      category: category,
      title: title,
      description: description,
      amount: amount,
      type: type,
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

