import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _hideOnboardingKey = 'hide_onboarding';

  Future<bool> getHideOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideOnboardingKey) ?? false;
  }

  
  Future<void> setHideOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideOnboardingKey, value);
  }
}
