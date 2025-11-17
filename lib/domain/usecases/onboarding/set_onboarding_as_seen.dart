import 'package:cashup/domain/repositories/onboarding_repository.dart';

class SetOnboardingAsSeen {
  final OnboardingRepository _repository;

  SetOnboardingAsSeen(this._repository);

  Future<void> call() async {
    await _repository.setOnboardingAsSeen();
  }
}

