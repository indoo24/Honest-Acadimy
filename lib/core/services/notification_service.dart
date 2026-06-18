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
  String? _currentUserId;

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
    } else {
      debugPrint('[NOTIFICATION] User denied or has not yet granted permission: ${settings.authorizationStatus}');
    }

    // Set iOS presentation options to show heads-up banners natively in the foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 3. Listen Foreground Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Token Refresh
    _fcm.onTokenRefresh.listen((token) {
      debugPrint('[FCM TOKEN] Refresh stream fired: $token');
      if (_currentUserId != null) {
        saveTokenToFirestore(_currentUserId!);
      }
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
    debugPrint('[NOTIFICATION SENT] Foreground message received: ${message.messageId}');
    final notification = message.notification;
    final android = message.notification?.android;

    // We only show local notifications on Android in the foreground because
    // on iOS, setForegroundNotificationPresentationOptions shows it natively.
    if (notification != null && Platform.isAndroid) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['path'],
      );
      debugPrint('[NOTIFICATION] Local notification shown for Android foreground message');
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
      debugPrint('[FCM TOKEN] Retrieved token: $token');
    } else {
      debugPrint('[FCM TOKEN] ❌ Retrived token was null');
    }
    return token;
  }

  Future<void> saveTokenToFirestore(String userId) async {
    _currentUserId = userId;
    final token = await getToken();
    if (token != null) {
      // 1. Save to users collection
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint('[NOTIFICATION] Token successfully saved/updated in users collection for: $userId');

      // 2. Save to coaches collection (if coach document exists)
      try {
        final coachDoc = await FirebaseFirestore.instance.collection('coaches').doc(userId).get();
        if (coachDoc.exists) {
          await FirebaseFirestore.instance.collection('coaches').doc(userId).set({
            'fcmToken': token,
          }, SetOptions(merge: true));
          debugPrint('[NOTIFICATION] Token successfully saved/updated in coaches collection for: $userId');
        } else {
          debugPrint('[NOTIFICATION] User is not a coach (no coach doc in coaches collection): $userId');
        }
      } catch (e) {
        debugPrint('[NOTIFICATION] ⚠️ Error checking/saving coach token for $userId: $e');
      }
    } else {
      debugPrint('[NOTIFICATION] ❌ Failed to retrieve FCM token for user: $userId - skipped saving');
    }
  }
}
