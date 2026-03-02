import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/config/network/dio.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> syncTokenWithServer(String fcmToken) async {
    try {
      // Check if user is logged in first
      final userToken = await TokenHandler.getString("token");
      if (userToken.isEmpty) return; // Do not send if not logged in

      final apiService = HTTP();
      await apiService.post(
        url: '/admin/fcm-tokens',
        data: {
          "token": fcmToken,
          "fcm_token": fcmToken, // Sending both in case backend expects one or the other
          "device_type": Platform.isIOS ? "ios" : "android",
          "device_info": Platform.isIOS ? "iOS Device" : "Android Device",
        },
      );
      debugPrint("✅ FCM Token seamlessly synced with backend server.");
    } on DioException catch (e) {
      debugPrint("❌ Failed to sync FCM token with server [DioException]: ${e.response?.statusCode}");
      debugPrint("❌ Backend Response Body: ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ Failed to sync FCM token with server: $e");
    }
  }

  Future<void> initNotifications() async {
    // 1. Request Permission (Required for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // 2. Get the FCM device token
      try {
        String? token = await _firebaseMessaging.getToken();
        debugPrint("📱 FCM Device Token: $token");
        
        // Save it locally so we can send it to the backend when logging in
        if (token != null) {
          await TokenHandler.setString("fcm_token", token);
          await syncTokenWithServer(token);
        }
      } catch (e) {
        debugPrint("Failed to get FCM token: $e");
      }

      // Automatically listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        debugPrint("📱 FCM Token Refreshed: $newToken");
        await TokenHandler.setString("fcm_token", newToken);
        await syncTokenWithServer(newToken);
      });

      // 3. Initialize background handlers (When app is completely closed or in background)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Listen for messages when the app is OPEN (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: \nTitle: ${message.notification?.title}\nBody: ${message.notification?.body}');
          // Note: In foreground, FCM doesn't show a head-up notification automatically by default. 
          // If you want a visual popup while the app is open, you need package like flutter_local_notifications.
        }
      });

      // 5. Handle when a user taps on a notification to open the app (App was in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
        debugPrint('Message data: ${message.data}');
      });

    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }
}
