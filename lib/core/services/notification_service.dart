import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request Permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[NOTIFICATION] User granted permission');
    }

    // 2. Local Notifications Setup for Foreground
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 3. Listen Foreground Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Token Refresh
    _fcm.onTokenRefresh.listen((token) {
      debugPrint('[FCM TOKEN] Refresh: $token');
      // We don't have the userId here, but saveTokenToFirestore 
      // can be called manually or we can store the current userId.
    });

    // 5. Handle Notification Taps (Background/Terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data['path']);
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data['path']);
    }

    _initialized = true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[NOTIFICATION SENT] Foreground message received');
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['path'],
      );
    }
  }

  void _handleNotificationTap(String? path) {
    if (path != null) {
      debugPrint('[NOTIFICATION] Handling tap for path: $path');
      // In a real app, you'd navigate here using your router.
      // Since we are just implementing the service, we log it.
    }
  }

  Future<String?> getToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      debugPrint('[FCM TOKEN] $token');
    }
    return token;
  }

  Future<void> saveTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint('[NOTIFICATION] Token saved for user: $userId');
    }
  }
}
