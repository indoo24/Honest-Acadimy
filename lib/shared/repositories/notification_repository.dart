import 'package:cloud_firestore/cloud_firestore.dart';
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
  }
}
