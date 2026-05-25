import 'package:honset_app/features/coaches/data/datasources/demo_coach_data.dart';
import 'package:honset_app/features/coaches/data/datasources/firestore_coach_data_source.dart';
import 'package:honset_app/features/coaches/data/models/coach_profile_model.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl({
    required FirestoreCoachDataSource? remoteDataSource,
    required bool firebaseEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _firebaseEnabled = firebaseEnabled;

  final FirestoreCoachDataSource? _remoteDataSource;
  final bool _firebaseEnabled;

  @override
  Future<List<CoachProfile>> getCoaches() async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        final coaches = await _remoteDataSource.getCoaches();
        if (coaches.isEmpty) {
          await _remoteDataSource.seedCoaches(_seedModels());
          return await _remoteDataSource.getCoaches();
        }
        return coaches;
      } on Object {
        return DemoCoachData.coaches;
      }
    }
    return DemoCoachData.coaches;
  }

  @override
  Stream<List<CoachProfile>> watchCoaches() async* {
    if (_firebaseEnabled && _remoteDataSource != null) {
      await getCoaches();
      yield* _remoteDataSource.watchCoaches();
      return;
    }
    yield DemoCoachData.coaches;
  }

  @override
  Stream<CoachProfile?> watchCoach(String coachId) async* {
    if (_firebaseEnabled && _remoteDataSource != null) {
      yield* _remoteDataSource.watchCoach(coachId);
      return;
    }
    yield DemoCoachData.coaches.firstWhere(
      (coach) => coach.id == coachId,
      orElse: () => DemoCoachData.coaches.first,
    );
  }

  List<CoachProfileModel> _seedModels() {
    return DemoCoachData.coaches
        .map(
          (coach) => CoachProfileModel.fromMap(
            CoachProfileModel(
              id: coach.id,
              name: coach.name,
              specialty: coach.specialty,
              yearsExperience: coach.yearsExperience,
              bio: coach.bio,
              rating: coach.rating,
              isActive: coach.isActive,
              availableSlots: coach.availableSlots,
              assignedCourts: coach.assignedCourts,
              imageUrl: coach.imageUrl,
              description: coach.description,
            ).toMap(),
          ),
        )
        .toList();
  }
}
