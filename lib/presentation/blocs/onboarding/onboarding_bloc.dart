import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashup/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:cashup/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:cashup/domain/usecases/onboarding/set_onboarding_as_seen.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  //Caso de uso para marcar el onboarding como visto
  final SetOnboardingAsSeen _setOnboardingAsSeen;
  static const int _totalPages = 3;


  OnboardingBloc(this._setOnboardingAsSeen) //SUPER: llama al constructor de la clase padre (Bloc) desde el hijo (OnboardingBloc)
    : super(const OnboardingInProgress(currentPage: 0)) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingSkipped>(_onSkipped);
    on<OnboardingCompleted>(_onCompleted);
  }

  Future<void> _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      OnboardingInProgress(
        currentPage: event.pageIndex,
        totalPages: _totalPages,
      ),
    );
  }

  Future<void> _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    final curreentState = state;

    if (curreentState is OnboardingInProgress) {
      if (!curreentState.isLastPage) {
        emit(
          OnboardingInProgress(
            currentPage: curreentState.currentPage + 1,
            totalPages: _totalPages,
          ),
        );
      } else {
        add(const OnboardingCompleted());
      }
    }
  }

  Future<void> _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) async {
    await _setOnboardingAsSeen();

    emit(const OnboardingFinished());
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await _setOnboardingAsSeen();
    emit(const OnboardingFinished());
  }
}
