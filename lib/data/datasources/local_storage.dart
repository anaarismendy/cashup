import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage{
  final SharedPreferences preferences;

  LocalStorage(this.preferences);

  static const String _onboardingKey = 'has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    return preferences.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingAsSeen() async {
    await preferences.setBool(_onboardingKey, true);
  }

  Future<void> resetOnboarding() async {
    await preferences.remove(_onboardingKey);
  }
}
