import 'package:honset_app/features/booking/domain/entities/court_availability.dart';

abstract class CourtAvailabilityRepository {
  /// Returns all court availability rules stored in Firestore.
  Future<List<CourtAvailability>> getAllAvailabilities();

  /// Returns the active availability rule for a specific court.
  Future<CourtAvailability?> getAvailabilityByCourtId(String courtId);
}

