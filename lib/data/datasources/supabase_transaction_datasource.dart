import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashup/data/models/transaction_model.dart';
import 'package:cashup/domain/entities/transaction_type.dart';

/// **SUPABASE_TRANSACTION_DATASOURCE**
/// 
/// Clase que maneja TODAS las interacciones con la tabla `transactions` de Supabase.
/// 
/// **Responsabilidades:**
/// - Obtener transacciones del usuario
/// - Crear nuevas transacciones
/// - Calcular resúmenes (balance, ingresos, gastos)
/// - Manejar errores de Supabase
class SupabaseTransactionDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseTransactionDataSource(this._supabaseClient);

  /// Obtiene todas las transacciones del usuario autenticado
  /// 
  /// **Parámetros:**
  /// - `limit`: Número máximo de transacciones a retornar (default: 10)
  /// - `orderBy`: Campo por el cual ordenar (default: 'transaction_date')
  /// - `ascending`: Si ordenar ascendente o descendente (default: false)
  /// 
  // Obtiene todas las transacciones del usuario autenticado
  /// 
  /// **Parámetros:**
  /// - `limit`: Número máximo de transacciones a retornar (default: 10)
  /// - `orderBy`: Campo por el cual ordenar (default: 'transaction_date')
  /// - `ascending`: Si ordenar ascendente o descendente (default: false)
  /// 
  /// **Retorna:**
  /// - Lista de transacciones del usuario
  /// 
  /// **Excepciones:**
  /// - `Exception('Usuario no autenticado')`: Si el usuario no está autenticado
  /// - `Exception('Error al obtener transacciones')`: Si hay un error al obtener las transacciones
  /// - `Exception('Error inesperado')`: Si hay un error inesperado
  Future<List<TransactionModel>> getTransactions({
    int limit = 10,
    String orderBy = 'transaction_date',
    bool ascending = false,
  }) async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Query con join a categories para obtener la categoría completa
      final response = await _supabaseClient
          .from('transactions')
          .select('''
            *,
            category:categories(*)
          ''')
          .eq('user_id', userId)
          .order(orderBy, ascending: ascending)
          .limit(limit);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener transacciones: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Crea una nueva transacción
  /// 
  /// **Parámetros:**
  /// - `title`: Título de la transacción
  /// - `amount`: Monto (siempre positivo)
  /// - `type`: Tipo de transacción (income o expense)
  /// - `categoryId`: ID de la categoría (opcional)
  /// - `description`: Descripción adicional (opcional)
  /// - `transactionDate`: Fecha de la transacción (default: hoy)
  Future<TransactionModel> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabaseClient
          .from('transactions')
          .insert({
            'user_id': userId,
            'title': title,
            'amount': amount,
            'type': type.toJson(),
            'category_id': categoryId,
            'description': description,
            'transaction_date': (transactionDate ?? DateTime.now())
                .toIso8601String()
                .split('T')[0], // Solo fecha
          })
          .select('''
            *,
            category:categories(*)
          ''')
          .single();

      return TransactionModel.fromJson(response);
    } on PostgrestException catch (e) {
      // Manejar errores específicos de validación
      // Si el mensaje contiene 'validate_transaction_category' o 'categoría no es válida' o 'category is not valid'
      if (e.message.contains('validate_transaction_category') ||
          e.message.contains('categoría no es válida') ||
          e.message.contains('category is not valid')) {
        throw Exception('La categoría no es válida para este usuario o tipo de transacción');
      }
      // Manejar errores de foreign key o constraint
      if (e.code == '23503' || e.message.contains('foreign key')) {
        throw Exception('La categoría seleccionada no existe o no es válida');
      }
      throw Exception('Error al crear transacción: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Obtiene el resumen financiero del usuario
  /// 
  /// **Usa la función RPC `get_user_balance` de Supabase:**
  /// Esta función calcula eficientemente en la base de datos:
  /// - Total de ingresos
  /// - Total de gastos
  /// - Balance (ingresos - gastos)
  /// 
  /// **Parámetros opcionales:**
  /// - `startDate`: Fecha de inicio para filtrar transacciones (opcional)
  /// - `endDate`: Fecha de fin para filtrar transacciones (opcional)
  /// 
  /// **Retorna:**
  /// - `totalIncome`: Suma de todos los ingresos
  /// - `totalExpenses`: Suma de todos los gastos
  /// - `balance`: Balance total (ingresos - gastos)
  Future<Map<String, double>> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Llamar a la función RPC de Supabase
      // La función retorna un array con un objeto que contiene los resultados
      final response = await _supabaseClient.rpc(
        'get_user_balance',
        params: {
          'p_user_id': userId,
          'p_start_date': startDate?.toIso8601String().split('T')[0], // Solo fecha
          'p_end_date': endDate?.toIso8601String().split('T')[0], // Solo fecha
        },
      );

      // La función RPC retorna un array con un objeto
      if (response == null || response.isEmpty) {
        // Si no hay resultados, retornar ceros
        return {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'balance': 0.0,
        };
      }

      // Obtener el primer (y único) resultado
      final result = response.first;

      // Extraer los valores de la respuesta
      // Nota: Los nombres de las columnas vienen en snake_case desde PostgreSQL
      final totalIncome = (result['total_income'] as num?)?.toDouble() ?? 0.0;
      final totalExpense = (result['total_expense'] as num?)?.toDouble() ?? 0.0;
      final balance = (result['balance'] as num?)?.toDouble() ?? 0.0;

      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpense,
        'balance': balance,
      };
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener resumen: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Obtiene transacciones recientes (últimas N transacciones)
  /// 
  /// **Parámetros:**
  /// - `limit`: Número de transacciones a retornar (default: 5)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    return getTransactions(
      limit: limit,
      orderBy: 'transaction_date',
      ascending: false,
    );
  }

  /// Obtiene una transacción por su ID
  /// 
  /// **Parámetros:**
  /// - `transactionId`: ID de la transacción a obtener
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabaseClient
          .from('transactions')
          .select('''
            *,
            category:categories(*)
          ''')
          .eq('id', transactionId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return TransactionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener transacción: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Actualiza una transacción existente usando la función RPC de Supabase
  /// 
  /// **Usa la función RPC `update_transaction` de Supabase:**
  /// Esta función maneja toda la lógica de validación y actualización
  /// en la base de datos, incluyendo:
  /// - Verificación de propiedad de la transacción
  /// - Validación de categoría y tipo
  /// - Validación de monto positivo
  /// 
  /// **Parámetros:**
  /// - `transactionId`: ID de la transacción a actualizar
  /// - `title`: Nuevo título (opcional)
  /// - `amount`: Nuevo monto (opcional)
  /// - `type`: Nuevo tipo (opcional)
  /// - `categoryId`: Nuevo ID de categoría (opcional, puede ser null)
  /// - `description`: Nueva descripción (opcional, puede ser null)
  /// - `transactionDate`: Nueva fecha (opcional)
  Future<TransactionModel> updateTransaction({
    required String transactionId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    DateTime? transactionDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Construir los parámetros para la función RPC
      final params = <String, dynamic>{
        'p_transaction_id': transactionId,
      };

      // Solo agregar parámetros que no sean null
      if (title != null) params['p_title'] = title;
      if (amount != null) params['p_amount'] = amount;
      if (type != null) params['p_type'] = type.toJson();
      if (categoryId != null) {
        params['p_category_id'] = categoryId.isEmpty ? null : categoryId;
      } else {
        // Si categoryId es null explícitamente (para eliminar categoría)
        // No lo incluimos en los parámetros, la función manejará el valor actual
      }
      if (description != null) {
        params['p_description'] = description.isEmpty ? null : description;
      }
      if (transactionDate != null) {
        params['p_transaction_date'] = transactionDate.toIso8601String().split('T')[0];
      }

      // Llamar a la función RPC
      final response = await _supabaseClient.rpc(
        'update_transaction',
        params: params,
      );

      // La función RPC retorna un array con la transacción actualizada
      if (response == null || response.isEmpty) {
        throw Exception('No se pudo actualizar la transacción');
      }

      final transactionData = response.first;

      // Obtener la categoría relacionada si existe
      String? categoryIdValue = transactionData['category_id'] as String?;
      Map<String, dynamic>? categoryData;

      if (categoryIdValue != null) {
        try {
          final categoryResponse = await _supabaseClient
              .from('categories')
              .select('*')
              .eq('id', categoryIdValue)
              .maybeSingle();
          
          if (categoryResponse != null) {
            categoryData = categoryResponse;
          }
        } catch (e) {
          // Si no se puede obtener la categoría, continuar sin ella
        }
      }

      // Construir el JSON completo con la categoría
      final completeData = Map<String, dynamic>.from(transactionData);
      if (categoryData != null) {
        completeData['category'] = categoryData;
      }

      return TransactionModel.fromJson(completeData);
    } on PostgrestException catch (e) {
      // La función RPC ya maneja los errores específicos
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Elimina una transacción usando la función RPC de Supabase
  /// 
  /// **Usa la función RPC `delete_transaction` de Supabase:**
  /// Esta función maneja toda la lógica de validación y eliminación
  /// en la base de datos, incluyendo:
  /// - Verificación de propiedad de la transacción
  /// - Validación de seguridad
  /// 
  /// **Parámetros:**
  /// - `transactionId`: ID de la transacción a eliminar
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Llamar a la función RPC
      await _supabaseClient.rpc(
        'delete_transaction',
        params: {
          'p_transaction_id': transactionId,
        },
      );
    } on PostgrestException catch (e) {
      // La función RPC ya maneja los errores específicos
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}

