import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/core/services/fcm_service.dart';
import 'package:honset_app/shared/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<AppNotification>> watchNotifications(String userId) {
    final collection = _firestore.collection('notifications');
    final query = collection
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
        
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      return docs.map((doc) {
        final data = doc.data();
        return AppNotification.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final doc = _firestore.collection('notifications').doc(notificationId);
    await doc.update({'isRead': true});
  }

  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    required String type,
    required String bookingId,
  }) async {
    // 1. Save in-app notification to Firestore.
    final collection = _firestore.collection('notifications');
    final docRef = collection.doc();
    final notification = AppNotification(
      id: docRef.id,
      receiverId: receiverId,
      title: title,
      body: body,
      type: type,
      bookingId: bookingId,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await docRef.set(notification.toFirestore());

    // 2. Send FCM push notification to the receiver's device.
    await _sendPushToUser(
      userId: receiverId,
      title: title,
      body: body,
      data: {
        'type': type,
        'bookingId': bookingId,
        'path': '/notifications',
      },
    );
  }

  Future<void> notifyAdmins({
    required String title,
    required String body,
    required String bookingId,
  }) async {
    final users = _firestore.collection('users');
    final adminsQuery = users.where('isAdmin', isEqualTo: true);
    final adminsSnapshot = await adminsQuery.get();

    final batch = _firestore.batch();
    final notifications = _firestore.collection('notifications');

    for (final doc in adminsSnapshot.docs) {
      final docRef = notifications.doc();
      final data = <String, dynamic>{
        'receiverId': doc.id,
        'title': title,
        'body': body,
        'type': 'booking_request',
        'bookingId': bookingId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(docRef, data);
    }

    await batch.commit();

    // Send FCM push notifications to all admins.
    for (final doc in adminsSnapshot.docs) {
      await _sendPushToUser(
        userId: doc.id,
        title: title,
        body: body,
        data: {
          'type': 'booking_request',
          'bookingId': bookingId,
          'path': '/admin',
        },
      );
    }
  }

  // ── Private helper ─────────────────────────────────────────────────────

  /// Looks up the user's FCM token from Firestore and sends a push
  /// notification if one is available.
  Future<void> _sendPushToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      debugPrint('[PUSH DIAGNOSTIC] Attempting to fetch FCM token for userId: $userId');
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      String? fcmToken = userDoc.data()?['fcmToken'] as String?;
      
      if (fcmToken != null && fcmToken.isNotEmpty) {
        debugPrint('[PUSH DIAGNOSTIC] Successfully fetched FCM token from users collection for userId: $userId. Token: $fcmToken');
      } else {
        debugPrint('[PUSH DIAGNOSTIC] FCM token not found in users collection for userId: $userId. Checking coaches collection...');
        final coachDoc = await _firestore.collection('coaches').doc(userId).get();
        fcmToken = coachDoc.data()?['fcmToken'] as String?;
        if (fcmToken != null && fcmToken.isNotEmpty) {
          debugPrint('[PUSH DIAGNOSTIC] Successfully fetched FCM token from coaches collection for userId: $userId. Token: $fcmToken');
        } else {
          debugPrint('[PUSH DIAGNOSTIC] ❌ FCM token is NULL or empty in both users and coaches collections for userId: $userId');
        }
      }

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('[PUSH] No FCM token for user $userId – skipping push.');
        return;
      }

      final success = await FCMService.instance.sendPushNotification(
        deviceToken: fcmToken,
        title: title,
        body: body,
        data: data,
      );
      
      debugPrint('[PUSH DIAGNOSTIC] sendPushNotification call result for user $userId: $success');
    } catch (e) {
      // Push failure should never block the in-app notification flow.
      debugPrint('[PUSH] ⚠️ Failed to send push to user $userId: $e');
    }
  }
}
