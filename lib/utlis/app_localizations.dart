class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'sound': 'Sound effects',
      'vibration': 'Vibration',
      'notifications': 'Daily notifications',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
    },
    'fr': {
      'settings': 'Paramètres',
      'sound': 'Effets sonores',
      'vibration': 'Vibration',
      'notifications': 'Notifications quotidiennes',
      'theme': 'Thème',
      'language': 'Langue',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
    },
    'ar': {
      'settings': 'الإعدادات',
      'sound': 'الصوت',
      'vibration': 'الاهتزاز',
      'notifications': 'الإشعارات اليومية',
      'theme': 'الوضع',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'النظام',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}