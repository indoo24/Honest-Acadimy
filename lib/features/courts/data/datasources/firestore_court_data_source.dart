import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/courts/data/models/court_model.dart';

class FirestoreCourtDataSource {
  FirestoreCourtDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<CourtModel>> getCourts() async {
    debugPrint('═══════════════════════════════════════════════');
    debugPrint('[🔥 COURTS QUERY] Collection: "courts"');
    debugPrint('[🔥 COURTS QUERY] Filter:   isActive == true');
    debugPrint('[🔥 COURTS QUERY] Order:    by name ascending');
    debugPrint('═══════════════════════════════════════════════');

    // Step 1: Fetch without filters to see ALL documents first
    try {
      final allDocs = await _firestore.collection('courts').get();
      debugPrint('[🔥 COURTS QUERY] TOTAL documents in "courts" collection: ${allDocs.docs.length}');
      if (allDocs.docs.isEmpty) {
        debugPrint('[🔥 COURTS QUERY] ❌ COLLECTION IS EMPTY! No court documents exist in Firestore.');
        debugPrint('[🔥 COURTS QUERY] ACTION: Go to Firestore console and add courts.');
        return [];
      }
      for (final doc in allDocs.docs) {
        final data = doc.data();
        debugPrint('───────────────────────────────────────────');
        debugPrint('[🔥 COURTS DOC] ID:   ${doc.id}');
        debugPrint('[🔥 COURTS DOC] Data: $data');
        // Check each field
        debugPrint('[🔥 COURTS DOC]   name          = ${data['name']} (${data['name'].runtimeType})');
        debugPrint('[🔥 COURTS DOC]   isActive      = ${data['isActive']} (${data['isActive'].runtimeType})');
        debugPrint('[🔥 COURTS DOC]   pricePerHour  = ${data['pricePerHour']} (${data['pricePerHour'].runtimeType})');
        debugPrint('[🔥 COURTS DOC]   hourlyRate    = ${data['hourlyRate']} (${data['hourlyRate'].runtimeType})');
        debugPrint('[🔥 COURTS DOC]   description   = ${data['description']} (${data['description'].runtimeType})');
        debugPrint('[🔥 COURTS DOC]   imageUrl      = ${data['imageUrl']} (${data['imageUrl'].runtimeType})');
      }
      debugPrint('───────────────────────────────────────────');

      // Step 2: Now try the FILTERED query (with where + orderBy)
      debugPrint('[🔥 COURTS QUERY] Attempting: .where("isActive", ==, true).orderBy("name")');
      debugPrint('[🔥 COURTS QUERY] ⚠️  This requires composite index: isActive ASC, name ASC');
      debugPrint('[🔥 COURTS QUERY] ⚠️  If this FAILS, deploy: firebase deploy --only firestore:indexes');

      final filteredSnapshot = await _firestore
          .collection('courts')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      debugPrint('[🔥 COURTS QUERY] Filtered result: ${filteredSnapshot.docs.length} courts returned');
      debugPrint('[🔥 COURTS QUERY] Documents passing filter:');
      for (final doc in filteredSnapshot.docs) {
        debugPrint('   ✅ ${doc.id}');
      }

      // Step 3: Diagnose WHY some docs were filtered OUT
      final passedIds = filteredSnapshot.docs.map((d) => d.id).toSet();
      for (final doc in allDocs.docs) {
        if (!passedIds.contains(doc.id)) {
          final data = doc.data();
          final isActive = data['isActive'];
          if (isActive == null) {
            debugPrint('[🔥 COURTS QUERY] ❌ SKIPPED: ${doc.id} -> isActive field is MISSING (null)');
          } else if (isActive is! bool) {
            debugPrint('[🔥 COURTS QUERY] ❌ SKIPPED: ${doc.id} -> isActive has WRONG TYPE: ${isActive.runtimeType} = $isActive (expected bool)');
          } else if (isActive == false) {
            debugPrint('[🔥 COURTS QUERY] ❌ SKIPPED: ${doc.id} -> isActive == false');
          } else {
            debugPrint('[🔥 COURTS QUERY] ❓ SKIPPED: ${doc.id} -> isActive is true but was excluded. Possible index mismatch.');
          }
        }
      }

      debugPrint('═══════════════════════════════════════════════');

      return filteredSnapshot.docs.map((doc) {
        try {
          final model = CourtModel.fromFirestore(doc);
          debugPrint('[🔥 COURT PARSED] ✅ ${doc.id}: name="${model.name}" price=\$${model.pricePerHour}');
          return model;
        } catch (e) {
          debugPrint('[🔥 COURT PARSED] ❌ FAILED to parse ${doc.id}: $e');
          rethrow;
        }
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('═══════════════════════════════════════════════');
      debugPrint('[🔥 COURTS ERROR] ❌ FIREBASE EXCEPTION');
      debugPrint('[🔥 COURTS ERROR]    code:    ${e.code}');
      debugPrint('[🔥 COURTS ERROR]    message: ${e.message}');
      debugPrint('[🔥 COURTS ERROR]    plugin:  ${e.plugin}');
      if (e.code == 'failed-precondition') {
        debugPrint('[🔥 COURTS ERROR] ⚠️  MISSING COMPOSITE INDEX!');
        debugPrint('[🔥 COURTS ERROR] 🔧 Create index: isActive ASC, name ASC');
        debugPrint('[🔥 COURTS ERROR] 🔧 Run: firebase deploy --only firestore:indexes');
        debugPrint('[🔥 COURTS ERROR] 🔧 Or create manually in Firestore console.');
      }
      debugPrint('═══════════════════════════════════════════════');
      rethrow;
    } catch (e) {
      debugPrint('[🔥 COURTS ERROR] ❌ UNEXPECTED ERROR: $e');
      rethrow;
    }
  }

  Stream<List<CourtModel>> watchCourts() {
    debugPrint('[🔥 COURTS STREAM] Starting real-time stream on "courts" collection');
    debugPrint('[🔥 COURTS STREAM] Filter:  isActive == true');
    debugPrint('[🔥 COURTS STREAM] Order:   name ascending');

    return _firestore
        .collection('courts')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          debugPrint('[🔥 COURTS STREAM] Snapshot received: ${snapshot.docs.length} documents');
          for (final change in snapshot.docChanges) {
            debugPrint(
              '[🔥 COURTS STREAM] Change: ${change.type.name} -> ${change.doc.id} (old=${change.oldIndex} new=${change.newIndex})',
            );
          }
          for (final doc in snapshot.docs) {
            final data = doc.data();
            debugPrint('[🔥 COURTS STREAM] Doc ${doc.id}: isActive=${data['isActive']} name=${data['name']}');
          }
          return snapshot.docs.map((doc) {
            try {
              return CourtModel.fromFirestore(doc);
            } catch (e) {
              debugPrint('[🔥 COURTS STREAM] ❌ Parsing failed for ${doc.id}: $e');
              rethrow;
            }
          }).toList();
        });
  }

  Future<CourtModel> getCourtById(String id) async {
    debugPrint('[🔥 COURTS BY ID] Fetching court: "$id"');
    final doc = await _firestore.collection('courts').doc(id).get();
    if (!doc.exists) {
      debugPrint('[🔥 COURTS BY ID] ❌ Court not found: "$id"');
      throw StateError('Court not found: $id');
    }
    final data = doc.data();
    debugPrint('[🔥 COURTS BY ID] Found: ${doc.id} -> $data');
    if (data == null) {
      debugPrint('[🔥 COURTS BY ID] ❌ Document has null data!');
      throw StateError('Court $id has null data');
    }
    try {
      final model = CourtModel.fromFirestore(doc);
      debugPrint('[🔥 COURTS BY ID] ✅ Parsed: name="${model.name}" price=\$${model.pricePerHour}');
      return model;
    } catch (e) {
      debugPrint('[🔥 COURTS BY ID] ❌ Parsing failed: $e');
      rethrow;
    }
  }

  Stream<CourtModel> watchCourtById(String id) {
    debugPrint('[🔥 COURTS STREAM BY ID] Watching court: "$id"');
    return _firestore.collection('courts').doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        debugPrint('[🔥 COURTS STREAM BY ID] ❌ Court not found (stream): "$id"');
        throw StateError('Court not found: $id');
      }
      return CourtModel.fromFirestore(doc);
    });
  }
}