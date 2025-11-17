import 'package:cashup/domain/entities/category_statistics_entity.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **CATEGORY_STATISTICS_MODEL (Modelo de Estadísticas de Categoría)**
/// 
/// Modelo de datos que convierte los datos de Supabase a la entidad de dominio.
/// Implementa el patrón de conversión de datos de la capa Data a Domain.
class CategoryStatisticsModel extends CategoryStatisticsEntity {
  const CategoryStatisticsModel({
    required super.categoryId,
    required super.categoryName,
    required super.categoryColor,
    required super.categoryIcon,
    required super.categoryType,
    required super.totalAmount,
    required super.transactionCount,
    required super.percentage,
  });

  /// Convierte un Map de Supabase a CategoryStatisticsModel
  /// 
  /// **Parámetros esperados de Supabase (función RPC get_category_statistics):**
  /// - category_id o id: UUID de la categoría
  /// - category_name o name: Nombre de la categoría
  /// - category_color o color: Color hexadecimal
  /// - category_icon o icon: Icono (emoji o código)
  /// - transaction_type o type: Tipo de transacción ('income' o 'expense')
  /// - total_amount: Total gastado/ingresado (NUMERIC)
  /// - transaction_count: Número de transacciones (BIGINT)
  /// - percentage: Porcentaje del total (NUMERIC)
  factory CategoryStatisticsModel.fromJson(Map<String, dynamic> json) {
    // La función RPC retorna category_id, category_name, transaction_type
    // pero también puede venir como id, name, type (por compatibilidad)
    final id = json['category_id'] ?? json['id'];
    final name = json['category_name'] ?? json['name'];
    final type = json['transaction_type'] ?? json['type'];
    final color = json['category_color'] ?? json['color'];
    final icon = json['category_icon'] ?? json['icon'];
    
    if (id == null || name == null || type == null) {
      throw Exception('Campos requeridos faltantes en estadísticas de categoría: category_id=$id, category_name=$name, transaction_type=$type');
    }

    return CategoryStatisticsModel(
      categoryId: id.toString(),
      categoryName: name.toString(),
      categoryColor: color?.toString() ?? '#6C5CE7',
      categoryIcon: icon?.toString() ?? '📁',
      categoryType: TransactionType.fromString(type.toString()),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convierte CategoryStatisticsModel a Map (útil para debugging)
  Map<String, dynamic> toJson() {
    return {
      'id': categoryId,
      'name': categoryName,
      'color': categoryColor,
      'icon': categoryIcon,
      'type': categoryType.toJson(),
      'total_amount': totalAmount,
      'transaction_count': transactionCount,
      'percentage': percentage,
    };
  }
}

