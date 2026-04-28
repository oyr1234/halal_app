import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 NEW

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/meal_suggestion_screen.dart';

import 'services/settings_service.dart';
import 'services/notification_service.dart';

import 'package:permission_handler/permission_handler.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 🔥 force logout كل مرة
  await FirebaseAuth.instance.signOut();

  await NotificationService.init();
  await Permission.notification.request();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final service = SettingsService();
        service.init();
        return service;
      },
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Halal Scanner',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AuthService().currentUser == null
                ? const LoginScreen()
                : HomeScreen(),
            routes: {
              '/settings': (context) => SettingsScreen(),
              '/meals': (context) => const MealSuggestionScreen(),
              '/signup': (context) => const SignupScreen(),
            },
          );
        },
      ),
    );
  }
}