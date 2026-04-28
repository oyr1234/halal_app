import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // 🔧 INIT
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  // 🔔 TEST notification (باش تتأكد يخدم)
  static Future<void> showDailyReminder() async {
    const android = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    await _notifications.show(
      0,
      'Halal Scanner',
      'Don\'t forget to check your products today!',
      details,
    );
  }

  // 🕘 SCHEDULE يومي
  static Future<void> scheduleDailyReminder() async {
    await _notifications.cancelAll();

    const android = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    final now = tz.TZDateTime.now(tz.local);

    // 🔥 test: notification بعد دقيقة
    final scheduled = now.add(const Duration(minutes: 1));

    await _notifications.zonedSchedule(
      0,
      'Halal Scanner',
      'Time to scan your groceries!',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ❌ cancel
  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}