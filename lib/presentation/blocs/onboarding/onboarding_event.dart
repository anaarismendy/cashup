import 'package:equatable/equatable.dart';


//SEALED: solo se puede extender dentro del archivo
sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}