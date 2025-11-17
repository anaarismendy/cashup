import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/domain/usecases/transactions/get_recent_transactions.dart';
import 'package:cashup/domain/usecases/transactions/get_transaction_summary.dart';
import 'package:cashup/presentation/blocs/home/home_event.dart';
import 'package:cashup/presentation/blocs/home/home_state.dart';

/// **HOME_BLOC**
/// 
/// Maneja toda la lógica de estado de la pantalla de home.
/// 
/// **Responsabilidades:**
/// - Cargar datos iniciales (balance, ingresos, gastos, transacciones recientes)
/// - Refrescar datos cuando el usuario hace pull-to-refresh
/// - Manejar eventos de navegación (agregar ingreso/gasto)
/// 
/// **Flujo típico:**
/// 1. UI envía evento (ej: HomeDataRequested)
/// 2. BLoC emite HomeLoading
/// 3. BLoC llama a los use cases correspondientes
/// 4. Use cases retornan datos o error
/// 5. BLoC emite HomeLoaded o HomeError
/// 6. UI reacciona al nuevo estado
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRecentTransactions _getRecentTransactions;
  final GetTransactionSummary _getTransactionSummary;

  HomeBloc({
    required GetRecentTransactions getRecentTransactions,
    required GetTransactionSummary getTransactionSummary,
  })  : _getRecentTransactions = getRecentTransactions,
        _getTransactionSummary = getTransactionSummary,
        super(const HomeInitial()) {
    // Registrar handlers de eventos
    on<HomeDataRequested>(_onDataRequested);
    on<HomeDataRefreshed>(_onDataRefreshed);
    on<HomeAddIncomePressed>(_onAddIncomePressed);
    on<HomeAddExpensePressed>(_onAddExpensePressed);
  }

  /// Maneja la carga inicial de datos
  Future<void> _onDataRequested(
    HomeDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Obtener resumen financiero y transacciones recientes en paralelo
      final summaryFuture = _getTransactionSummary();
      final transactionsFuture = _getRecentTransactions(limit: 5);

      final summary = await summaryFuture;
      final transactions = await transactionsFuture;

      emit(HomeLoaded(
        balance: summary['balance'] ?? 0.0,
        totalIncome: summary['totalIncome'] ?? 0.0,
        totalExpenses: summary['totalExpenses'] ?? 0.0,
        recentTransactions: transactions,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Maneja el refresh de datos
  Future<void> _onDataRefreshed(
    HomeDataRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    // Si ya hay datos cargados, mantenerlos mientras se refresca
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith());
    } else {
      emit(const HomeLoading());
    }

    try {
      // Obtener resumen financiero y transacciones recientes en paralelo
      final summaryFuture = _getTransactionSummary();
      final transactionsFuture = _getRecentTransactions(limit: 5);

      final summary = await summaryFuture;
      final transactions = await transactionsFuture;

      emit(HomeLoaded(
        balance: summary['balance'] ?? 0.0,
        totalIncome: summary['totalIncome'] ?? 0.0,
        totalExpenses: summary['totalExpenses'] ?? 0.0,
        recentTransactions: transactions,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Maneja el evento de agregar ingreso
  /// Por ahora solo emite el estado actual (la navegación se maneja en la UI)
  void _onAddIncomePressed(
    HomeAddIncomePressed event,
    Emitter<HomeState> emit,
  ) {
    // La navegación se maneja en la UI, no aquí
    // Este evento puede usarse para logging o analytics en el futuro
  }

  /// Maneja el evento de agregar gasto
  /// Por ahora solo emite el estado actual (la navegación se maneja en la UI)
  void _onAddExpensePressed(
    HomeAddExpensePressed event,
    Emitter<HomeState> emit,
  ) {
    // La navegación se maneja en la UI, no aquí
    // Este evento puede usarse para logging o analytics en el futuro
  }
}

