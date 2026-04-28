import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const _channelId = 'meal_reminder_channel';
  static const _channelName = 'Meal Reminders';

  // ─────────────────────────────
  // INIT
  // ─────────────────────────────
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  // ─────────────────────────────
  // NOTIFICATION DETAILS
  // ─────────────────────────────
  static NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Reminders to plan and log your meals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  // ─────────────────────────────
  // INSTANT (test / manual trigger)
  // ─────────────────────────────
  static Future<void> showInstantReminder() async {
    await _notifications.show(
      0,
      '🍽️ Meal Planner',
      "What are you eating today? Let's plan your meals!",
      _details,
    );
  }

  // ─────────────────────────────
  // SCHEDULE DAILY at a given hour:minute
  // ─────────────────────────────
  static Future<void> scheduleDailyReminder({
    int hour = 9,
    int minute = 0,
  }) async {
    await _notifications.cancelAll();

    final now = tz.TZDateTime.now(tz.local);

    // Build next occurrence of hour:minute
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If already past today's time, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1,
      '🍽️ Meal Planner',
      "Time to discover new meal ideas based on what's in your kitchen!",
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─────────────────────────────
  // SCHEDULE MULTIPLE reminders
  // e.g. breakfast / lunch / dinner prompts
  // ─────────────────────────────
  static Future<void> scheduleAllMealReminders() async {
    await _notifications.cancelAll();

    final reminders = [
      (id: 1, hour: 8,  minute: 0,  title: '🌅 Good morning!',   body: "Plan today's meals before you get busy."),
      (id: 2, hour: 12, minute: 0,  title: '🥗 Lunch time!',     body: 'Need meal ideas? Open the app and get inspired.'),
      (id: 3, hour: 18, minute: 30, title: '🍳 Dinner is near!', body: "What's for dinner? Check what you can cook tonight."),
    ];

    for (final r in reminders) {
      final now = tz.TZDateTime.now(tz.local);

      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        r.hour,
        r.minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        r.id,
        r.title,
        r.body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ─────────────────────────────
  // CANCEL ALL
  // ─────────────────────────────
  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}