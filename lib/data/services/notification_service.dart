import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles scheduling gentle daily reminders, e.g. "How are you feeling
/// today?" — kept opt-in and easy to turn off in settings.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
  }

  Future<void> showDailyCheckInReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_checkin',
      'Daily Check-In',
      channelDescription: 'Gentle reminder to log how you are feeling',
      importance: Importance.low,
      priority: Priority.low,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      0,
      'How are you feeling today?',
      'Take a moment for a quick mood check-in 🌿',
      details,
    );
  }

  // TODO: use zonedSchedule + timezone package for a recurring daily time,
  // e.g. every evening at 8 PM, once you decide on the reminder cadence.
}
