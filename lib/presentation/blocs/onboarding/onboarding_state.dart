import 'package:equatable/equatable.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

//Estado inicial del onboarding
class OnboardingInitial extends OnboardingState {
  final int currentPage;

  const OnboardingInitial({this.currentPage = 0});

  @override
  List<Object?> get props => [currentPage];
}

//Cuando el usuario está navegando entre las páginas o viendo una página en particular
class OnboardingInProgress extends OnboardingState {
  final int currentPage;
  final int totalPages;

  const OnboardingInProgress({
    required this.currentPage, 
    this.totalPages = 3
    });

  bool get isLastPage => currentPage == totalPages -1;

  @override
  List<Object?> get props => [currentPage, totalPages];
}

class OnboardingFinished extends OnboardingState {
  const OnboardingFinished();
}