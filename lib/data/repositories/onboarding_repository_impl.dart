import 'package:cashup/data/datasources/local_storage.dart';
import 'package:cashup/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {

final LocalStorage _localStorage;

OnboardingRepositoryImpl(this._localStorage);

@override
  Future<bool> hasSeenOnboarding() async {
    return await _localStorage.hasSeenOnboarding();
  }

  @override
  Future<void> setOnboardingAsSeen() async {
    await _localStorage.setOnboardingAsSeen();
  }

}
