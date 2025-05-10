import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false; // New flag for dark mode

  bool _isFirstTimeUser = true;

  bool get isDarkMode => _isDarkMode;
  bool get isFirstTimeUser => _isFirstTimeUser;

  SettingsProvider() {
    _loadTheme();
    _loadFirstTimeUser();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", _isDarkMode);
    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool("isDarkMode") ?? false;
    notifyListeners();
  }

  void saveFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstTimeUser", false);
    notifyListeners();
  }

  void _loadFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTimeUser = prefs.getBool("isFirstTimeUser") ?? true;
    notifyListeners();
  }
}
