import 'package:honset_app/features/courts/data/datasources/demo_club_data.dart';
import 'package:honset_app/features/courts/data/datasources/firestore_court_data_source.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';

class CourtRepositoryImpl implements CourtRepository {
  CourtRepositoryImpl({
    required FirestoreCourtDataSource? remoteDataSource,
    required bool firebaseEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _firebaseEnabled = firebaseEnabled;

  final FirestoreCourtDataSource? _remoteDataSource;
  final bool _firebaseEnabled;

  @override
  Future<List<Court>> getCourts() async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        final courts = await _remoteDataSource.getCourts();
        if (courts.isNotEmpty) return courts;
      } on Object {
        return DemoClubData.courts;
      }
    }
    return DemoClubData.courts;
  }

  @override
  Future<Court> getCourtById(String id) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.getCourtById(id);
      } on Object {
        return DemoClubData.courts.firstWhere((court) => court.id == id);
      }
    }
    return DemoClubData.courts.firstWhere((court) => court.id == id);
  }
}
