import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honset_app/features/courts/data/models/court_model.dart';

class FirestoreCourtDataSource {
  FirestoreCourtDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<CourtModel>> getCourts() async {
    final snapshot = await _firestore
        .collection('courts')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snapshot.docs.map(CourtModel.fromFirestore).toList();
  }

  Future<CourtModel> getCourtById(String id) async {
    final doc = await _firestore.collection('courts').doc(id).get();
    if (!doc.exists) throw StateError('Court not found');
    return CourtModel.fromFirestore(doc);
  }
}
