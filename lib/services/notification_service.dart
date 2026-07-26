import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize Local Notification plugin and channels
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('[NotificationService] Notification clicked: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  /// Request Post Notifications permission on Android 13+
  static Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Show instant test notification with random VocabItem from user's vault
  static Future<void> showPassiveVocabNotification(List<VocabItem> vocabList) async {
    await initialize();

    final isGranted = await requestNotificationPermission();
    if (!isGranted) {
      debugPrint('[NotificationService] Notification permission denied');
      return;
    }

    // Priority filter: Only pick words that user is actively learning or needs to review!
    final learningItems = vocabList.where((v) =>
      v.masteryStatus == MasteryStatus.learning || v.masteryStatus == MasteryStatus.review
    ).toList();

    final candidateList = learningItems.isNotEmpty ? learningItems : vocabList;

    final vocab = candidateList.isNotEmpty
        ? candidateList[Random().nextInt(candidateList.length)]
        : VocabItem(
            id: 'demo',
            word: 'Spearheaded',
            phonetic: '/ˈspɪər.hed.ɪd/',
            definition: 'To lead an attack or course of action.',
            contextSentence: 'I spearheaded a comprehensive system audit.',
            indonesianMeaning: 'Memimpin / Pelopor akselerasi',
            addedAt: DateTime.now(),
          );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'bemind_passive_learning',
      'BeMind Passive Learning Flashcard',
      channelDescription: 'On-device periodic flashcard notifications on lockscreen',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final title = '🧠 Kosa Kata: ${vocab.word} ${vocab.phonetic}';
    final body = 'Arti: ${vocab.indonesianMeaning}\n📝 Contoh: "${vocab.contextSentence.isNotEmpty ? vocab.contextSentence : vocab.definition}"';

    await _notificationsPlugin.show(
      Random().nextInt(10000),
      title,
      body,
      platformChannelSpecifics,
      payload: vocab.word,
    );
  }
}
