import 'package:honset_app/features/booking/data/datasources/firestore_schedule_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({required FirestoreScheduleDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FirestoreScheduleDataSource _remoteDataSource;

  @override
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  }) {
    return _remoteDataSource.getSlots(date: date, courtId: courtId);
  }

  @override
  Stream<List<BookingSlot>> watchSlots({
    required DateTime date,
    required String courtId,
  }) {
    return _remoteDataSource.watchSlots(date: date, courtId: courtId);
  }
}
