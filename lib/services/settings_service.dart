import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsService extends ChangeNotifier {
  // ─── defaults ───
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  // ─────────────────────────────
  // INIT
  // ─────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    final theme = prefs.getString('themeMode') ?? 'system';
    _themeMode = theme == 'light'
        ? ThemeMode.light
        : theme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.system;

    final lang = prefs.getString('language') ?? 'en';
    _locale = Locale(lang);

    // Re-schedule reminders on app start if they were enabled
    if (_notificationsEnabled) {
      await NotificationService.scheduleAllMealReminders();
    }

    notifyListeners();
  }

  // ─────────────────────────────
  // SETTERS
  // ─────────────────────────────
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);

    if (value) {
      // Schedule breakfast / lunch / dinner reminders
      await NotificationService.scheduleAllMealReminders();
    } else {
      await NotificationService.cancelAllReminders();
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();

    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';

    await prefs.setString('themeMode', value);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}