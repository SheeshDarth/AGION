import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb, debugPrint;
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> init() async {
    if (!_supported) return;
    try {
      tz_data.initializeTimeZones();

      // Set local timezone — use UTC as safe default if detection fails
      try {
        // Try to use system timezone offset to pick a reasonable location
        final offset = DateTime.now().timeZoneOffset;
        final offsetHours = offset.inHours;
        // Map offset to a known tz location
        final tzName = _tzFromOffset(offsetHours);
        tz.setLocalLocation(tz.getLocation(tzName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings);
      _initialized = true;

      await _scheduleAll();
    } catch (e) {
      // Never crash the app because of notifications
      debugPrint('NotificationService init error (non-fatal): $e');
    }
  }

  static String _tzFromOffset(int offsetHours) {
    // Simplified mapping — covers common zones
    const map = {
      -12: 'Etc/GMT+12',
      -11: 'Pacific/Samoa',
      -10: 'Pacific/Honolulu',
      -9:  'America/Anchorage',
      -8:  'America/Los_Angeles',
      -7:  'America/Denver',
      -6:  'America/Chicago',
      -5:  'America/New_York',
      -4:  'America/Halifax',
      -3:  'America/Sao_Paulo',
      -2:  'Etc/GMT+2',
      -1:  'Atlantic/Azores',
       0:  'Europe/London',
       1:  'Europe/Paris',
       2:  'Europe/Athens',
       3:  'Europe/Moscow',
       4:  'Asia/Dubai',
       5:  'Asia/Karachi',
       6:  'Asia/Dhaka',
       7:  'Asia/Bangkok',
       8:  'Asia/Shanghai',
       9:  'Asia/Tokyo',
      10:  'Australia/Sydney',
      11:  'Pacific/Noumea',
      12:  'Pacific/Auckland',
    };
    // IST is +5:30 — offset in hours is 5, but we handle the half-hour case
    if (offsetHours == 5) {
      // Could be IST (+5:30) or PKT (+5:00); default to IST
      return 'Asia/Kolkata';
    }
    return map[offsetHours] ?? 'UTC';
  }

  static Future<void> _scheduleAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
      await _schedule(id: 1, hour: 8,  minute: 0,
          title: '◈ AGION SYSTEM',
          body: '◈ SYSTEM: Daily missions loaded. Initiate ascension.');
      await _schedule(id: 2, hour: 19, minute: 0,
          title: '◈ AGION SYSTEM',
          body: '◈ SYSTEM: Combat training unregistered. Streak at risk.');
      await _schedule(id: 3, hour: 22, minute: 45,
          title: '◈ AGION SYSTEM',
          body: '◈ SYSTEM: Daily reset in 75 minutes. Complete active quests.');
    } catch (e) {
      debugPrint('NotificationService schedule error (non-fatal): $e');
    }
  }

  static Future<void> _schedule({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'agion_system',
            'AGION System',
            channelDescription: 'AGION ascension notifications',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF7EC8E3),
          ),
        ),
        // Use inexact — works without SCHEDULE_EXACT_ALARM special permission
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService _schedule($id) error (non-fatal): $e');
    }
  }

  static Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    if (!_supported || !_initialized) return;
    try {
      await _plugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'agion_system',
            'AGION System',
            channelDescription: 'AGION ascension notifications',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF7EC8E3),
          ),
        ),
      );
    } catch (e) {
      debugPrint('NotificationService showImmediate error (non-fatal): $e');
    }
  }
}
