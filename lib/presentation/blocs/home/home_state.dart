import 'package:equatable/equatable.dart';
import 'package:cashup/domain/entities/transaction_entity.dart';

/// **HOME_STATE (Estados de la Pantalla de Home)**
/// 
/// Representa los diferentes estados en los que puede estar la pantalla de home.
/// 
/// Sealed class para que no se pueda instanciar, solo extendiendo la clase
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - No hay datos cargados aún
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Cargando datos
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Datos cargados exitosamente
class HomeLoaded extends HomeState {
  /// Balance total (ingresos - gastos)
  final double balance;
  
  /// Total de ingresos
  final double totalIncome;
  
  /// Total de gastos
  final double totalExpenses;
  
  /// Transacciones recientes
  final List<TransactionEntity> recentTransactions;

  const HomeLoaded({
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        balance,
        totalIncome,
        totalExpenses,
        recentTransactions,
      ];

  HomeLoaded copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpenses,
    List<TransactionEntity>? recentTransactions,
  }) {
    return HomeLoaded(
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }
}

/// Error al cargar datos
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

