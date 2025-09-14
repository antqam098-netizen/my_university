import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../../data/datasources/local_db.dart';
import '../../data/models/lecture.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showDailyAt6() async {
    const detail = AndroidNotificationDetails(
        'daily6', 'Daily Summary',
        importance: Importance.high, priority: Priority.high);
    const platform = NotificationDetails(android: detail);

    final now = DateTime.now();
    final todayLecs = await LocalDB.fetchByDay(_dayArabic(now.weekday % 7));
    final payload =
        'اليوم لديك ${todayLecs.length} محاضرة'; // can parse later

    await _plugin.periodicallyShow(
        99, 'صباح الخير', payload, RepeatInterval.daily, platform,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  static Future<void> scheduleLecture(Lecture lec) async {
    final day = _dayToInt(lec.day);
    final now = DateTime.now();
    final scheduled = DateTime(
        now.year, now.month, now.day + ((day - now.weekday + 7) % 7));
    final parts = lec.startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final notifyTime = scheduled
        .add(Duration(hours: hour, minutes: minute))
        .subtract(const Duration(minutes: 30));

    if (notifyTime.isBefore(now)) return;

    const detail = AndroidNotificationDetails(
        'lec30', 'قبل المحاضرة',
        importance: Importance.high, priority: Priority.high);
    const platform = NotificationDetails(android: detail);

    await _plugin.zonedSchedule(
        lec.id ?? 1000,
        lec.name,
        '${lec.type} | ${lec.place} | ${lec.doctor ?? ''}',
        notifyTime,
        platform,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  static String _dayArabic(int w) {
    const d = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return d[w];
  }

  static int _dayToInt(String day) {
    const d = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return d.indexOf(day) + 1;
  }
}
