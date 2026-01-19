import 'package:Outbox/models/membership_card_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
//import 'package:khyate_b2b/models/membership_card_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'api_service.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _timezoneConfigured = false;

  static Future<void> initialize() async {
    if (kIsWeb || _initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    await _configureLocalTimeZone();
    await requestPermissions();
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  static Future<void> scheduleUpcomingSessions(
      List<MembershipCardData> sessions) async {
    if (kIsWeb || !_initialized) return;

    for (final session in sessions) {
      await scheduleReminderForSession(session);
    }
  }

  static Future<void> scheduleReminderForSession(
      MembershipCardData session) async {
    if (kIsWeb || !_initialized) return;

    final eventDateTime = _parseEventDateTime(session.date, session.time);
    if (eventDateTime == null) return;

    final reminderDateTime = eventDateTime.subtract(const Duration(hours: 6));
    if (reminderDateTime.isBefore(DateTime.now())) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'session_reminders',
        'Session Reminders',
        channelDescription: 'Reminders for upcoming sessions and events.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      session.id.hashCode,
      'Upcoming session: ${session.title}',
      'Starts at ${session.time} in ${session.location}. See you there!',
      tz.TZDateTime.from(reminderDateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: session.id,
    );
  }

  static DateTime? _parseEventDateTime(String date, String time) {
    final parsedDate = _parseDate(date);
    final parsedTime = _parseTime(time);

    if (parsedDate == null || parsedTime == null) {
      return null;
    }

    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day,
        parsedTime.hour, parsedTime.minute);
  }

  static DateTime? _parseDate(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    final formats = [
      DateFormat('dd-MM-yyyy'),
      DateFormat('MM-dd-yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
    ];

    for (final format in formats) {
      try {
        return format.parseStrict(cleaned);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static DateTime? _parseTime(String raw) {
    final cleaned = raw.trim().toUpperCase();
    if (cleaned.isEmpty) return null;

    final formats = [
      DateFormat('hh:mm A'),
      DateFormat('h:mm A'),
      DateFormat('HH:mm'),
    ];

    for (final format in formats) {
      try {
        final parsed = format.parseStrict(cleaned);
        return DateTime(0, 1, 1, parsed.hour, parsed.minute);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static Future<void> _configureLocalTimeZone() async {
    if (_timezoneConfigured || kIsWeb) return;

    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timezoneConfigured = true;
  }

  // 2.15 Update Notification (API endpoint)
  static Future<void> updateNotification({
    required String notificationId,
    required bool isRead,
  }) async {
    try {
      final response = await ApiService.put(
        'https://outbox.nablean.com/api/v1/user/update-notification/$notificationId',
        {'isRead': isRead},
        requireAuth: true,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to update notification');
      }
    } catch (e) {
      throw Exception('Update notification error: ${e.toString()}');
    }
  }

  // Get all notifications from API
  static Future<List<dynamic>> getAllNotifications() async {
    try {
      final response = await ApiService.get(
        'https://outbox.nablean.com/api/v1/user/get-all-notification',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get notifications');
      }
    } catch (e) {
      throw Exception('Get notifications error: ${e.toString()}');
    }
  }
}

