import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';

/// Service managing on-device local notifications for subscription and recurring bill reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelId = 'hermanos_subscriptions';
  static const String channelName = 'Subscription & Bill Reminders';
  static const String channelDesc = 'Alerts for upcoming recurring subscriptions and bills';

  /// Initialize local notifications and timezone data.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create Android high-importance notification channel
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        const channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.high,
        );

        await androidImpl?.createNotificationChannel(channel);
        await androidImpl?.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Derives a stable integer notification ID for a rule and daysBefore trigger.
  int _deriveNotificationId(String ruleId, int daysBefore) {
    final base = ruleId.hashCode.abs() % 100000;
    return (base * 10) + daysBefore;
  }

  /// Schedules 3 notification reminders (7 days, 3 days, 1 day before due date).
  Future<void> scheduleSubscriptionReminders(RecurringModel rule) async {
    if (!_isInitialized) await initialize();

    // If rule is paused or notifications are disabled, cancel any scheduled reminders
    if (!rule.isActive || !rule.enableNotifications) {
      await cancelSubscriptionReminders(rule.id);
      return;
    }

    final intervals = [7, 3, 1]; // 1 week before, 3 days before, 1 day before
    final now = DateTime.now();

    for (final days in intervals) {
      final notifId = _deriveNotificationId(rule.id, days);

      // Calculate reminder date at 9:00 AM
      final targetDate = DateTime(
        rule.nextDueDate.year,
        rule.nextDueDate.month,
        rule.nextDueDate.day,
        9,
        0,
      ).subtract(Duration(days: days));

      if (targetDate.isAfter(now)) {
        final title = days == 1
            ? 'Due Tomorrow: ${rule.title}'
            : 'Upcoming: ${rule.title} in $days days';

        final body = days == 1
            ? '${rule.title} (${CurrencyFormatter.format(rule.amount)}) is due tomorrow.'
            : '${rule.title} (${CurrencyFormatter.format(rule.amount)}) is due in $days days on ${_formatDate(rule.nextDueDate)}.';

        try {
          await _plugin.zonedSchedule(
            id: notifId,
            title: title,
            body: body,
            scheduledDate: tz.TZDateTime.from(targetDate, tz.local),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                channelName,
                channelDescription: channelDesc,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (e) {
          debugPrint('Exact alarm failed for ${rule.title} ($days days): $e, trying inexact fallback');
          try {
            await _plugin.zonedSchedule(
              id: notifId,
              title: title,
              body: body,
              scheduledDate: tz.TZDateTime.from(targetDate, tz.local),
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  channelId,
                  channelName,
                  channelDescription: channelDesc,
                  importance: Importance.high,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            );
          } catch (e2) {
            debugPrint('Failed to schedule reminder for ${rule.title} ($days days): $e2');
          }
        }
      } else {
        // Cancel if this specific trigger date has already passed
        await _plugin.cancel(id: notifId);
      }
    }
  }

  /// Cancels all scheduled reminder triggers for a specific recurring rule.
  Future<void> cancelSubscriptionReminders(String ruleId) async {
    if (!_isInitialized) return;
    for (final days in [7, 3, 1]) {
      final notifId = _deriveNotificationId(ruleId, days);
      await _plugin.cancel(id: notifId);
    }
  }

  /// Synchronizes reminders for all active rules with notifications enabled.
  Future<void> syncAllReminders(List<RecurringModel> rules) async {
    for (final rule in rules) {
      await scheduleSubscriptionReminders(rule);
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
