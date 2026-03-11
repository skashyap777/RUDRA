import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/config/network/dio.dart';

// Initialize the local notifications plugin
final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel', // id (must match AndroidManifest.xml)
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;

  // If there's a notification payload, use its title/body.
  // Otherwise, fallback to checking data payload for custom title/body keys.
  final title = notification?.title ?? data['title'] ?? 'New Notification';
  final body =
      notification?.body ??
      data['body'] ??
      data['message'] ??
      'You have a new update.';

  // On Android, if Firebase already shows a system notification for the background,
  // we don't want to duplicate it. We only manually show if notification payload was null
  // (meaning it was a data-only push) or if we are handling it in FOREGROUND.
  await _localNotificationsPlugin.show(
    id: message.hashCode,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: data.toString(),
  );
  debugPrint("✅ Foreground notification manually displayed!");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");

  // If it's a data-only payload, the OS doesn't automatically show it when the app is closed.
  // So we trigger the local notification manually.
  if (message.notification == null) {
    await _showLocalNotification(message);
  }
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> syncTokenWithServer(String fcmToken) async {
    try {
      final userToken = await TokenHandler.getString("token");
      if (userToken.isEmpty) return;

      final apiService = HTTP();
      await apiService.post(
        url: '/admin/fcm-tokens',
        data: {
          "token": fcmToken,
          "fcm_token": fcmToken,
          "device_type": Platform.isIOS ? "ios" : "android",
          "device_info": Platform.isIOS ? "iOS Device" : "Android Device",
        },
      );
      debugPrint("✅ FCM Token synced.");
    } catch (e) {
      debugPrint("❌ Failed to sync FCM token: $e");
    }
  }

  Future<void> initNotifications() async {
    // 1. Setup local notifications for Android
    if (Platform.isAndroid) {
      final androidImplementation =
          _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.createNotificationChannel(_channel);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Tapped local notification: ${response.payload}');
      },
    );

    // 2. Request FCM permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Update foreground notification presenation options for iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      // 3. Get token
      try {
        String? token = await _firebaseMessaging.getToken();
        debugPrint("📱 FCM Device Token: $token");
        if (token != null) {
          await TokenHandler.setString("fcm_token", token);
          await syncTokenWithServer(token);
        }
      } catch (e) {
        debugPrint("Failed to get FCM token: $e");
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await TokenHandler.setString("fcm_token", newToken);
        await syncTokenWithServer(newToken);
      });

      // 4. Background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 5. Foreground handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got foreground message: ${message.messageId}');
        // Show manual local notification when app is open (Foreground)
        _showLocalNotification(message);
      });

      // 6. Tapped notification while in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
      });
    } else {
      debugPrint('User declined permission');
    }
  }
}
