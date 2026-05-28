import 'package:flutter/foundation.dart';
import 'package:honset_app/features/courts/data/datasources/firestore_court_data_source.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';

class CourtRepositoryImpl implements CourtRepository {
  CourtRepositoryImpl({required FirestoreCourtDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FirestoreCourtDataSource _remoteDataSource;

  @override
  Future<List<Court>> getCourts() async {
    debugPrint('[🏛️ REPO] CourtRepository.getCourts() called');
    debugPrint('[🏛️ REPO] Delegating to FirestoreCourtDataSource.getCourts()');
    try {
      final courts = await _remoteDataSource.getCourts();
      debugPrint('[🏛️ REPO] ✅ getCourts() returned ${courts.length} courts');
      for (final court in courts) {
        debugPrint('[🏛️ REPO]   - id="${court.id}" name="${court.name}" active=${court.isActive} price=\$${court.pricePerHour}');
      }
      if (courts.isEmpty) {
        debugPrint('[🏛️ REPO] ⚠️  WARNING: 0 courts returned!');
        debugPrint('[🏛️ REPO] ⚠️  Possible causes:');
        debugPrint('[🏛️ REPO] ⚠️   1. No documents in "courts" Firestore collection');
        debugPrint('[🏛️ REPO] ⚠️   2. All courts have isActive=false');
        debugPrint('[🏛️ REPO] ⚠️   3. Missing composite index (isActive ASC, name ASC)');
        debugPrint('[🏛️ REPO] ⚠️   4. Field name mismatch (old docs use different field names)');
        debugPrint('[🏛️ REPO] ⚠️   5. All courts have pricePerHour=null or invalid type');
      }
      return courts;
    } catch (e) {
      debugPrint('[🏛️ REPO] ❌ getCourts() FAILED: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Court>> watchCourts() {
    debugPrint('[🏛️ REPO] CourtRepository.watchCourts() called');
    debugPrint('[🏛️ REPO] Delegating to FirestoreCourtDataSource.watchCourts()');
    return _remoteDataSource.watchCourts();
  }

  @override
  Future<Court> getCourtById(String id) async {
    debugPrint('[🏛️ REPO] CourtRepository.getCourtById("$id") called');
    try {
      final court = await _remoteDataSource.getCourtById(id);
      debugPrint('[🏛️ REPO] ✅ getCourtById("$id") -> "$court"');
      return court;
    } catch (e) {
      debugPrint('[🏛️ REPO] ❌ getCourtById("$id") FAILED: $e');
      rethrow;
    }
  }

  @override
  Stream<Court> watchCourtById(String id) {
    debugPrint('[🏛️ REPO] CourtRepository.watchCourtById("$id") called');
    return _remoteDataSource.watchCourtById(id);
  }
}