import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Sound effects'),
            value: settings.soundEnabled,
            onChanged: settings.setSoundEnabled,
          ),
          SwitchListTile(
            title: Text('Vibration'),
            value: settings.vibrationEnabled,
            onChanged: settings.setVibrationEnabled,
          ),
          SwitchListTile(
            title: Text('Daily reminder notifications'),
            value: settings.notificationsEnabled,
            onChanged: settings.setNotificationsEnabled,
          ),
          ListTile(
            title: Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              ],
              onChanged: (val) => settings.setThemeMode(val!),
            ),
          ),
          ListTile(
            title: Text('Language'),
            trailing: DropdownButton<Locale>(
              value: settings.locale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
                DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
              ],
              onChanged: (val) => settings.setLocale(val!),
            ),
          ),
        ],
      ),
    );
  }
}