import 'package:honset_app/features/courts/domain/entities/court.dart';

abstract class CourtRepository {
  Future<List<Court>> getCourts();

  Stream<List<Court>> watchCourts();

  Future<Court> getCourtById(String id);

  Stream<Court> watchCourtById(String id);
}