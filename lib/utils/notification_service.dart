import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ikt205g26v_04/storage/note.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(settings: settings);

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> showNoteCreatedNotification(Note note) async {
    const androidDetails = AndroidNotificationDetails('cloudnotes', 'CloudNotes', importance: Importance.max, priority: Priority.high);

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(id: 0, title: 'New note created', body: note.title, notificationDetails: notificationDetails, payload: note.title);
  }
}
