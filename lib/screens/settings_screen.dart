import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../utlis/app_localizations.dart'; // 🔥 IMPORTANT

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);

    final t = AppLocalizations(settings.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('settings')),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(t.translate('sound')),
            value: settings.soundEnabled,
            onChanged: (val) => settings.setSoundEnabled(val),
          ),
          SwitchListTile(
            title: Text(t.translate('vibration')),
            value: settings.vibrationEnabled,
            onChanged: (val) => settings.setVibrationEnabled(val),
          ),
          SwitchListTile(
            title: Text(t.translate('notifications')),
            value: settings.notificationsEnabled,
            onChanged: (val) => settings.setNotificationsEnabled(val),
          ),
          ListTile(
            title: Text(t.translate('theme')),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(t.translate('light')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(t.translate('dark')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(t.translate('system')),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  settings.setThemeMode(val);
                }
              },
            ),
          ),
          ListTile(
            title: Text(t.translate('language')),
            trailing: DropdownButton<Locale>(
              value: settings.locale,
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: const Locale('fr'),
                  child: Text('Français'),
                ),
                DropdownMenuItem(
                  value: const Locale('ar'),
                  child: Text('العربية'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  settings.setLocale(val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}