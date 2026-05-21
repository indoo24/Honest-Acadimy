import 'package:honset_app/features/courts/domain/entities/court.dart';

abstract class CourtRepository {
  Future<List<Court>> getCourts();

  Future<Court> getCourtById(String id);
}
