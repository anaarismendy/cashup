import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cashup/core/constants/app_colors.dart';
import 'package:cashup/core/constants/app_strings.dart';
import 'package:cashup/domain/entities/daily_summary_entity.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_event.dart';
import 'package:cashup/presentation/blocs/statistics/statistics_state.dart';
import 'package:cashup/presentation/widgets/statistics/donut_chart_widget.dart';
import 'package:cashup/presentation/widgets/statistics/category_progress_list_widget.dart';
import 'package:cashup/presentation/widgets/common/bottom_navigation_bar_widget.dart';

/// **STATISTICS_SCREEN (Pantalla de Estadísticas)**
/// 
/// Muestra estadísticas financieras con:
/// - Resumen de ingresos, gastos y balance
/// - Gráfica de donut con distribución de gastos
/// - Lista de gastos por categoría con barras de progreso
/// - Filtros por período (Semana, Mes, Año, Personalizado)
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    context.read<StatisticsBloc>().add(const StatisticsDataRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigationBarWidget(
        currentLocation: GoRouterState.of(context).matchedLocation,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          AppStrings.statistics,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsInitial || state is StatisticsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is StatisticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StatisticsBloc>().add(
                            const StatisticsDataRequested(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is StatisticsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StatisticsBloc>().add(
                      const StatisticsDataRequested(),
                    );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtros de período
                    _buildPeriodFilters(context, state),
                    const SizedBox(height: 16),
                    // Selector de fecha específica
                    _buildDateSelector(context, state),
                    const SizedBox(height: 16),
                    // Toggle para mostrar solo gastos diarios
                    _buildDailyOnlyToggle(context, state),
                    const SizedBox(height: 24),
                    // Resumen de ingresos, gastos y balance
                    _buildSummaryCard(state),
                    const SizedBox(height: 24),
                    // Gráfica de donut (solo si no está en modo solo diarios)
                    if (!state.showDailyOnly)
                      DonutChartWidget(
                        categoryStatistics: state.categoryStatistics,
                        totalExpenses: state.totalExpenses,
                      ),
                    if (!state.showDailyOnly) const SizedBox(height: 24),
                    // Lista de gastos por categoría o resúmenes diarios
                    if (state.showDailyOnly)
                      _buildDailyExpensesList(state)
                    else
                      CategoryProgressListWidget(
                        categoryStatistics: state.categoryStatistics,
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Construye los filtros de período (Día, Semana, Mes, Año)
  Widget _buildPeriodFilters(BuildContext context, StatisticsLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodButton(
            context,
            label: AppStrings.day,
            period: StatisticsPeriod.day,
            isSelected: state.period == StatisticsPeriod.day,
          ),
          const SizedBox(width: 12),
          _buildPeriodButton(
            context,
            label: AppStrings.week,
            period: StatisticsPeriod.week,
            isSelected: state.period == StatisticsPeriod.week,
          ),
          const SizedBox(width: 12),
          _buildPeriodButton(
            context,
            label: AppStrings.month,
            period: StatisticsPeriod.month,
            isSelected: state.period == StatisticsPeriod.month,
          ),
          const SizedBox(width: 12),
          _buildPeriodButton(
            context,
            label: AppStrings.year,
            period: StatisticsPeriod.year,
            isSelected: state.period == StatisticsPeriod.year,
          ),
        ],
      ),
    );
  }

  /// Construye un botón de período
  Widget _buildPeriodButton(
    BuildContext context, {
    required String label,
    required StatisticsPeriod period,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        final currentState = context.read<StatisticsBloc>().state;
        if (currentState is StatisticsLoaded) {
          // Mantener la fecha seleccionada actual al cambiar de período
          context.read<StatisticsBloc>().add(
                StatisticsPeriodChanged(period),
              );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.indicatorInactive,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Construye el selector de fecha específica
  Widget _buildDateSelector(BuildContext context, StatisticsLoaded state) {
    String dateLabel;
    switch (state.period) {
      case StatisticsPeriod.day:
        dateLabel = DateFormat('dd/MM/yyyy').format(state.selectedDate);
        break;
      case StatisticsPeriod.week:
        final weekStart = state.startDate;
        final weekEnd = state.endDate;
        dateLabel = '${DateFormat('dd/MM').format(weekStart)} - ${DateFormat('dd/MM/yyyy').format(weekEnd)}';
        break;
      case StatisticsPeriod.month:
        dateLabel = DateFormat('MMMM yyyy', 'es').format(state.selectedDate);
        break;
      case StatisticsPeriod.year:
        dateLabel = state.selectedDate.year.toString();
        break;
    }

    return GestureDetector(
      onTap: () => _showDatePicker(context, state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.indicatorInactive,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra el selector de fecha según el período
  Future<void> _showDatePicker(BuildContext context, StatisticsLoaded state) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2, 1, 1);
    final lastDate = now;

    DateTime? picked;

    // Configuración común del builder para todos los casos
    // Usamos el contexto original para mantener acceso a MaterialLocalizations
    Widget datePickerBuilder(BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      );
    }

    switch (state.period) {
      case StatisticsPeriod.day:
        picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('es', 'ES'),
          builder: datePickerBuilder,
        );
        break;
      case StatisticsPeriod.week:
        // Para semana, seleccionar cualquier día de la semana deseada
        picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('es', 'ES'),
          builder: datePickerBuilder,
        );
        break;
      case StatisticsPeriod.month:
        // Para mes, usar un selector de año y mes
        picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('es', 'ES'),
          initialDatePickerMode: DatePickerMode.year,
          builder: datePickerBuilder,
        );
        break;
      case StatisticsPeriod.year:
        // Para año, usar selector de año
        picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('es', 'ES'),
          initialDatePickerMode: DatePickerMode.year,
          builder: datePickerBuilder,
        );
        break;
    }

    if (picked != null && context.mounted) {
      context.read<StatisticsBloc>().add(
            StatisticsDateSelected(
              period: state.period,
              selectedDate: picked,
            ),
          );
    }
  }

  /// Construye el toggle para mostrar solo gastos diarios
  Widget _buildDailyOnlyToggle(BuildContext context, StatisticsLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.indicatorInactive,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.showDailyExpensesOnly,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: state.showDailyOnly,
            onChanged: (value) {
              context.read<StatisticsBloc>().add(
                    StatisticsShowDailyOnlyChanged(value),
                  );
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Construye la lista de gastos diarios
  Widget _buildDailyExpensesList(StatisticsLoaded state) {
    if (state.dailySummaries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No hay gastos diarios registrados',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos Diarios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...state.dailySummaries
              .where((summary) => summary.dailyExpense > 0)
              .map((summary) => _buildDailyExpenseItem(summary)),
        ],
      ),
    );
  }

  /// Construye un item de gasto diario
  Widget _buildDailyExpenseItem(DailySummaryEntity summary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDailyDate(summary.transactionDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.transactionCount} transacciones',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            NumberFormat.currency(
              symbol: '\$',
              decimalDigits: 0,
            ).format(summary.dailyExpense),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea la fecha para mostrar en la lista de gastos diarios
  String _formatDailyDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy, ${DateFormat('dd MMMM').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Ayer, ${DateFormat('dd MMMM').format(date)}';
    } else {
      // Días de la semana en español
      final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
                      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
      return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
    }
  }

  /// Construye la tarjeta de resumen (Ingresos, Gastos, Balance)
  Widget _buildSummaryCard(StatisticsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Ingresos
          _buildSummaryItem(
            label: AppStrings.income,
            amount: state.totalIncome,
            color: AppColors.income,
          ),
          // Gastos
          _buildSummaryItem(
            label: AppStrings.expenses,
            amount: state.totalExpenses,
            color: AppColors.expense,
          ),
          // Balance
          _buildSummaryItem(
            label: AppStrings.balance,
            amount: state.balance,
            color: state.balance >= 0 ? AppColors.income : AppColors.expense,
          ),
        ],
      ),
    );
  }

  /// Construye un item del resumen
  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(
            symbol: '\$',
            decimalDigits: 0,
          ).format(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

