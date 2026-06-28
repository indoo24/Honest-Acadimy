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
    if (kDebugMode) {
      debugPrint('[🏛️ REPO] CourtRepository.getCourts()');
    }
    final courts = await _remoteDataSource.getCourts();
    if (kDebugMode && courts.isEmpty) {
      debugPrint('[🏛️ REPO] ⚠️ 0 courts returned — check Firestore data / indexes');
    }
    return courts;
  }

  @override
  Stream<List<Court>> watchCourts() {
    if (kDebugMode) {
      debugPrint('[🏛️ REPO] CourtRepository.watchCourts()');
    }
    return _remoteDataSource.watchCourts();
  }

  @override
  Future<Court> getCourtById(String id) async {
    if (kDebugMode) {
      debugPrint('[🏛️ REPO] CourtRepository.getCourtById("$id")');
    }
    return _remoteDataSource.getCourtById(id);
  }

  @override
  Stream<Court> watchCourtById(String id) {
    if (kDebugMode) {
      debugPrint('[🏛️ REPO] CourtRepository.watchCourtById("$id")');
    }
    return _remoteDataSource.watchCourtById(id);
  }
}
