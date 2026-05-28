import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honset_app/features/booking/data/models/court_availability_model.dart' as model_pkg;
import 'package:honset_app/features/booking/domain/entities/court_availability.dart' as entity_pkg;
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';

class CourtAvailabilityRepositoryImpl implements CourtAvailabilityRepository {
  CourtAvailabilityRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  final Map<String, entity_pkg.CourtAvailability> _cacheByCourt = {};
  List<entity_pkg.CourtAvailability>? _cacheAll;

  @override
  Future<List<entity_pkg.CourtAvailability>> getAllAvailabilities() async {
    if (_cacheAll != null) return _cacheAll!;
    final snapshot = await _firestore.collection('courtAvailability').get();
    final availabilities = snapshot.docs
        .map((doc) => model_pkg.CourtAvailabilityModel.fromFirestore(doc))
        .map((model) => entity_pkg.CourtAvailability(
              courtId: model.courtId,
              workingDays: model.workingDays,
              startHour: model.startHour,
              endHour: model.endHour,
              slotDurationMinutes: model.slotDurationMinutes,
              breaks: model.breaks
                  .map((b) => entity_pkg.BreakPeriod(startHour: b.startHour, endHour: b.endHour))
                  .toList(),
              isActive: model.isActive,
            ))
        .toList();
    for (final availability in availabilities) {
      _cacheByCourt[availability.courtId] = availability;
    }
    _cacheAll = availabilities;
    return availabilities;
  }

  @override
  Future<entity_pkg.CourtAvailability?> getAvailabilityByCourtId(String courtId) async {
    final cached = _cacheByCourt[courtId];
    if (cached != null) {
      return cached.isActive ? cached : null;
    }
    final snapshot = await _firestore
        .collection('courtAvailability')
        .where('courtId', isEqualTo: courtId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final model = model_pkg.CourtAvailabilityModel.fromFirestore(snapshot.docs.first);
    final availability = entity_pkg.CourtAvailability(
      courtId: model.courtId,
      workingDays: model.workingDays,
      startHour: model.startHour,
      endHour: model.endHour,
      slotDurationMinutes: model.slotDurationMinutes,
      breaks: model.breaks
          .map((b) => entity_pkg.BreakPeriod(startHour: b.startHour, endHour: b.endHour))
          .toList(),
      isActive: model.isActive,
    );
    _cacheByCourt[courtId] = availability;
    return availability;
  }
}

