import 'package:cashup/domain/repositories/onboarding_repository.dart';

class CheckOnboardingStatus {
  final OnboardingRepository _repository;

  CheckOnboardingStatus(this._repository);

  Future<bool> call() async {
    return await _repository.hasSeenOnboarding();
  }
}

