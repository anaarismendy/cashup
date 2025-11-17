import 'package:equatable/equatable.dart';

/// **HOME_EVENT (Eventos de la Pantalla de Home)**
/// 
/// Acciones que el usuario puede realizar en la pantalla de home.
/// 
/// Sealed class para que no se pueda instanciar, solo extendiendo la clase
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Carga los datos iniciales de la pantalla de home
/// Se dispara cuando la pantalla se carga por primera vez
class HomeDataRequested extends HomeEvent {
  const HomeDataRequested();
}

/// Refresca los datos de la pantalla de home
/// Se dispara cuando el usuario hace pull-to-refresh
class HomeDataRefreshed extends HomeEvent {
  const HomeDataRefreshed();
}

/// Usuario presiona el botón "+ Ingreso"
class HomeAddIncomePressed extends HomeEvent {
  const HomeAddIncomePressed();
}

/// Usuario presiona el botón "+ Gasto"
class HomeAddExpensePressed extends HomeEvent {
  const HomeAddExpensePressed();
}

