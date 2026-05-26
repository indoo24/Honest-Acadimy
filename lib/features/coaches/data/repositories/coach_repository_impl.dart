import 'package:honset_app/features/coaches/data/datasources/firestore_coach_data_source.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl({required FirestoreCoachDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FirestoreCoachDataSource _remoteDataSource;

  @override
  Future<List<CoachProfile>> getCoaches() async {
    return _remoteDataSource.getCoaches();
  }

  @override
  Stream<List<CoachProfile>> watchCoaches() {
    return _remoteDataSource.watchCoaches();
  }

  @override
  Stream<CoachProfile?> watchCoach(String coachId) {
    return _remoteDataSource.watchCoach(coachId);
  }
}