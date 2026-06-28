import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/courts/data/models/court_model.dart';

class FirestoreCourtDataSource {
  FirestoreCourtDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// In-memory cache to avoid redundant Firestore reads.
  List<CourtModel>? _courtsCache;

  /// Clears the in-memory cache so the next [getCourts] call hits Firestore.
  void invalidateCache() {
    _courtsCache = null;
  }

  Future<List<CourtModel>> getCourts({bool forceRefresh = false}) async {
    if (!forceRefresh && _courtsCache != null) {
      if (kDebugMode) {
        debugPrint('[🔥 COURTS QUERY] Returning ${_courtsCache!.length} courts from cache');
      }
      return _courtsCache!;
    }

    if (kDebugMode) {
      debugPrint('[🔥 COURTS QUERY] Fetching courts: isActive == true, orderBy name');
    }

    final snapshot = await _firestore
        .collection('courts')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();

    if (kDebugMode) {
      debugPrint('[🔥 COURTS QUERY] Returned ${snapshot.docs.length} courts');
    }

    final courts = snapshot.docs.map((doc) {
      try {
        return CourtModel.fromFirestore(doc);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[🔥 COURTS QUERY] ❌ Failed to parse ${doc.id}: $e');
        }
        rethrow;
      }
    }).toList();

    _courtsCache = courts;
    return courts;
  }

  Stream<List<CourtModel>> watchCourts() {
    if (kDebugMode) {
      debugPrint('[🔥 COURTS STREAM] Starting real-time stream');
    }

    return _firestore
        .collection('courts')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          if (kDebugMode) {
            debugPrint('[🔥 COURTS STREAM] Snapshot: ${snapshot.docs.length} docs');
          }
          final courts = snapshot.docs.map((doc) {
            try {
              return CourtModel.fromFirestore(doc);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('[🔥 COURTS STREAM] ❌ Parse failed ${doc.id}: $e');
              }
              rethrow;
            }
          }).toList();
          // Keep cache in sync with stream updates.
          _courtsCache = courts;
          return courts;
        });
  }

  Future<CourtModel> getCourtById(String id) async {
    if (kDebugMode) {
      debugPrint('[🔥 COURTS BY ID] Fetching court: "$id"');
    }
    final doc = await _firestore.collection('courts').doc(id).get();
    if (!doc.exists) {
      throw StateError('Court not found: $id');
    }
    final data = doc.data();
    if (data == null) {
      throw StateError('Court $id has null data');
    }
    return CourtModel.fromFirestore(doc);
  }

  Stream<CourtModel> watchCourtById(String id) {
    return _firestore.collection('courts').doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw StateError('Court not found: $id');
      }
      return CourtModel.fromFirestore(doc);
    });
  }
}
