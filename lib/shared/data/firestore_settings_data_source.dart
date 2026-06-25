import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSettingsDataSource {
  FirestoreSettingsDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Fetches the InstaPay payment link from the `settings/payment_info` document.
  ///
  /// Throws a [StateError] if the document or field is missing.
  Future<String> getInstaPayLink() async {
    final doc = await _firestore.collection('settings').doc('payment_info').get();

    if (!doc.exists) {
      throw StateError('Payment settings document not found in Firestore.');
    }

    final data = doc.data();
    final link = data?['instaPayLink'] as String?;

    if (link == null || link.isEmpty) {
      throw StateError('instaPayLink field is missing or empty.');
    }

    return link;
  }
}
