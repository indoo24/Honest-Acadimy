import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';

abstract class CoachRepository {
  Future<List<CoachProfile>> getCoaches();

  Stream<List<CoachProfile>> watchCoaches();

  Stream<CoachProfile?> watchCoach(String coachId);
}
