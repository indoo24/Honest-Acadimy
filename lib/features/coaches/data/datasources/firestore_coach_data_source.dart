import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/coaches/data/models/coach_profile_model.dart';

class FirestoreCoachDataSource {
  FirestoreCoachDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<CoachProfileModel>> getCoaches() async {
    debugPrint('[HOME QUERY] Firestore coaches.getCoaches()');
    final snapshot = await _firestore
        .collection('coaches')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    debugPrint(
      '[HOME QUERY] Firestore coaches.getCoaches() -> ${snapshot.docs.length}',
    );
    return snapshot.docs
        .map((doc) => CoachProfileModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Stream<List<CoachProfileModel>> watchCoaches() {
    debugPrint('[HOME QUERY] Firestore coaches.watchCoaches() subscribe');
    return _firestore
        .collection('coaches')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CoachProfileModel.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Stream<CoachProfileModel?> watchCoach(String coachId) {
    return _firestore
        .collection('coaches')
        .doc(coachId)
        .snapshots()
        .map(
          (snapshot) => snapshot.data() == null
              ? null
              : CoachProfileModel.fromMap(snapshot.data()!, id: snapshot.id),
        );
  }

  Future<void> seedCoaches(List<CoachProfileModel> coaches) async {
    final collection = _firestore.collection('coaches');
    final batch = _firestore.batch();
    for (final coach in coaches) {
      batch.set(
        collection.doc(coach.id),
        coach.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
