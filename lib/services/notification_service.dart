import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String waterTaskName = 'waterReminder';
const String notificationChannelId = 'fittrack_water';
const String notificationChannelName = 'Lembrete de Água';
const String notificationChannelDesc = 'Lembretes para beber água';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('water_reminder_enabled') ?? true;
    if (!enabled) return true;

    await NotificationService().showWaterNotification();
    return true;
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<void> showWaterNotification() async {
    const androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      notificationChannelName,
      channelDescription: notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💧 Hora de beber água!',
      'Mantenha-se hidratado durante o treino!',
      details,
    );
  }

  Future<void> scheduleWaterReminders() async {
    await Workmanager().cancelAll();
    await Workmanager().registerPeriodicTask(
      waterTaskName,
      waterTaskName,
      frequency: const Duration(hours: 1),
    );
  }

  Future<void> cancelWaterReminders() async {
    await Workmanager().cancelAll();
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
    return true;
  }
}
