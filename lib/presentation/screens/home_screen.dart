import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/core/di/injector.dart';
import 'package:cashup/domain/entities/transaction_type.dart';
import 'package:cashup/presentation/blocs/auth/auth_bloc.dart';
import 'package:cashup/presentation/blocs/auth/auth_event.dart';
import 'package:cashup/presentation/blocs/auth/auth_state.dart';
import 'package:cashup/presentation/blocs/home/home_bloc.dart';
import 'package:cashup/presentation/blocs/home/home_event.dart';
import 'package:cashup/presentation/blocs/home/home_state.dart';
import 'package:cashup/presentation/blocs/add_transaction/add_transaction_bloc.dart';
import 'package:cashup/presentation/widgets/home/balance_card.dart';
import 'package:cashup/presentation/widgets/home/transaction_card.dart';
import 'package:cashup/presentation/widgets/home/empty_transactions_widget.dart';
import 'package:cashup/presentation/widgets/common/bottom_navigation_bar_widget.dart';
import 'package:cashup/presentation/screens/add_transaction_screen.dart';

/// **HOME_SCREEN (Pantalla de Inicio)**
/// 
/// Pantalla principal de la aplicación que muestra:
/// - Saludo personalizado con nombre del usuario
/// - Balance total, ingresos y gastos
/// - Botones para agregar ingresos y gastos
/// - Lista de movimientos recientes
/// 
/// **Diseño basado en las imágenes adjuntas:**
/// - Fondo claro (AppColors.background)
/// - Cards blancos con sombras suaves
/// - Colores verde para ingresos, rojo para gastos
/// - Botones grandes y redondeados
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Método público para refrescar los datos desde widgets hijos
  void refreshData() {
    if (mounted) {
      context.read<HomeBloc>().add(const HomeDataRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Si el usuario se desautentica (logout), redirigir al login
        if (authState is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          final userName = user?.profile?.fullName ?? AppStrings.guest;

        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: BottomNavigationBarWidget(
            // Obtener la ruta actual de la navegación
            currentLocation: GoRouterState.of(context).matchedLocation,
          ),
          body: SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                // Cargar datos cuando se monta la pantalla
                if (state is HomeInitial) {
                  // Agregar el evento para cargar los datos
                  // El HomeDataRequested es un evento que se encarga de cargar los datos de la pantalla de inicio

                  context.read<HomeBloc>().add(const HomeDataRequested());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const HomeDataRefreshed());
                    // Esperar un poco para que el refresh indicator se muestre
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    // Configurar el scroll para que siempre se pueda scrollar
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Configurar el padding para que el contenido se muestre correctamente
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saludo y nombre del usuario
                        _buildHeader(userName),
                        const SizedBox(height: 24),

                        // Card de Balance
                        if (state is HomeLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (state is HomeLoaded)
                          BalanceCard(
                            balance: state.balance,
                            totalIncome: state.totalIncome,
                            totalExpenses: state.totalExpenses,
                          )
                        else if (state is HomeError)
                          _buildErrorCard(state.message)
                        else
                          const SizedBox.shrink(),

                        const SizedBox(height: 24),

                        // Botones de acción
                        if (state is! HomeLoading) _buildActionButtons(context),

                        const SizedBox(height: 32),

                        // Título "Transacciones"
                        const Text(
                          AppStrings.allTransactions,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de transacciones recientes
                        if (state is HomeLoading)
                          const SizedBox.shrink()
                        else if (state is HomeLoaded)
                          state.recentTransactions.isEmpty
                              ? const EmptyTransactionsWidget()
                              : Column(
                                  children: state.recentTransactions
                                      .map((transaction) => TransactionCard(
                                            transaction: transaction,
                                          ))
                                      .toList(),
                                )
                        else if (state is HomeError)
                          const SizedBox.shrink()
                        else
                          const EmptyTransactionsWidget(),

                        // Espacio al final para el scroll
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        },
      ),
    );
  }

  /// Construye el header con saludo y nombre
  Widget _buildHeader(String userName) {
    // Construir el header con saludo y nombre
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.hello,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        // Menú de perfil con opción de cerrar sesión
        // PopupMenuButton es un widget que muestra un menú emergente cuando se presiona
        PopupMenuButton<String>(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
            ),
          ),
          //roundedRectangleBorder es un widget que muestra un borde redondeado
          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.cardBackground,
          elevation: 8,
          onSelected: (value) {
            if (value == 'logout') {
              // Cerrar sesión
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.logout,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye los botones de acción (+ Ingreso y + Gasto)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Botón "+ Ingreso" (verde)
        Expanded(
          child: _buildActionButton(
            context: context,
            label: AppStrings.addIncome,
            color: AppColors.income,
            icon: Icons.add,
            onPressed: () {
              context.read<HomeBloc>().add(const HomeAddIncomePressed());
              _showAddTransactionModal(context, TransactionType.income);
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Botón "+ Gasto" (rojo)
        Expanded(
          child: _buildActionButton(
            context: context,
            label: AppStrings.addExpense,
            color: AppColors.expense,
            icon: Icons.remove,
            onPressed: () {
              context.read<HomeBloc>().add(const HomeAddExpensePressed());
              _showAddTransactionModal(context, TransactionType.expense);
            },
          ),
        ),
      ],
    );
  }

  /// Construye un botón de acción individual
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un card de error
  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el modal para agregar transacción
  Future<void> _showAddTransactionModal(BuildContext context, TransactionType type) async {
    // Guardar referencia al BLoC antes del await para evitar usar context después
    final bloc = context.read<HomeBloc>();
    
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => sl<AddTransactionBloc>(),
        child: AddTransactionScreen(initialType: type),
      ),
    );

    // Si la transacción fue guardada exitosamente, refrescar los datos
    // Usamos la referencia del BLoC guardada antes del await
    if (result == true) {
      bloc.add(const HomeDataRefreshed());
    }
  }
}
