import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CATEGORY_STATISTICS_ENTITY (Entidad de Estadísticas de Categoría)**
/// 
/// Representa las estadísticas de una categoría específica.
/// Incluye el total gastado/ingresado, el porcentaje del total y el número de transacciones.
class CategoryStatisticsEntity extends Equatable {
  /// ID de la categoría
  final String categoryId;
  
  /// Nombre de la categoría
  final String categoryName;
  
  /// Color de la categoría (hexadecimal)
  final String categoryColor;
  
  /// Icono de la categoría
  final String categoryIcon;
  
  /// Tipo de transacción (income o expense)
  final TransactionType categoryType;
  
  /// Total de dinero en esta categoría
  final double totalAmount;
  
  /// Número de transacciones en esta categoría
  final int transactionCount;
  
  /// Porcentaje del total (0-100)
  final double percentage;

  const CategoryStatisticsEntity({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.categoryType,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryColor,
        categoryIcon,
        categoryType,
        totalAmount,
        transactionCount,
        percentage,
      ];
}

