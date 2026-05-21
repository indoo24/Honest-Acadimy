import 'package:honset_app/core/constants/app_constants.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/coach.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class DemoClubData {
  const DemoClubData._();

  static const AppUser demoUser = AppUser(
    id: 'guest-member',
    name: 'Guest Member',
    email: 'guest@honset.club',
    membershipTier: MembershipTier.guest,
    isAdmin: false,
  );

  static const List<Court> courts = [
    Court(
      id: 'court-1',
      name: 'Court One',
      description: 'Championship glass-back court with spectator seating.',
      imageUrl: '',
      surface: CourtSurface.glassBack,
      hourlyRate: 32,
      isActive: true,
      coach: Coach(
        id: 'coach-amira',
        name: 'Amira Hassan',
        specialty: 'Footwork and match tactics',
        rating: 4.9,
        imageUrl: '',
      ),
    ),
    Court(
      id: 'court-2',
      name: 'Court Two',
      description: 'Training court tuned for fast drills and private lessons.',
      imageUrl: '',
      surface: CourtSurface.traditional,
      hourlyRate: 28,
      isActive: true,
      coach: Coach(
        id: 'coach-karim',
        name: 'Karim Nabil',
        specialty: 'Power play and endurance',
        rating: 4.8,
        imageUrl: '',
      ),
    ),
  ];

  static List<BookingSlot> slotsFor(DateTime date, String courtId) {
    final now = DateTime.now();
    final slots = <BookingSlot>[];
    for (
      var hour = AppConstants.openingHour;
      hour < AppConstants.closingHour;
      hour++
    ) {
      final start = DateTime(date.year, date.month, date.day, hour);
      final end = start.add(
        const Duration(minutes: AppConstants.bookingDurationMinutes),
      );
      final seed = hour + courtId.hashCode + date.day;
      final status = start.isBefore(now)
          ? SlotStatus.past
          : seed % 7 == 0
          ? SlotStatus.pending
          : seed % 5 == 0
          ? SlotStatus.reserved
          : SlotStatus.available;
      slots.add(
        BookingSlot(
          id: '$courtId-${start.millisecondsSinceEpoch}',
          courtId: courtId,
          startsAt: start,
          endsAt: end,
          status: status,
          bookingId: status == SlotStatus.available ? null : 'booking-$seed',
        ),
      );
    }
    return slots;
  }

  static List<Booking> bookingsFor(String userId) {
    final base = DateTime.now().add(const Duration(days: 1));
    return [
      Booking(
        id: 'BK-1009',
        userId: userId,
        userName: demoUser.name,
        courtId: 'court-1',
        courtName: 'Court One',
        coachName: 'Amira Hassan',
        startsAt: DateTime(base.year, base.month, base.day, 18),
        endsAt: DateTime(base.year, base.month, base.day, 19),
        status: BookingStatus.confirmed,
        amount: 32,
        qrPayload: 'HONSET:BK-1009',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Booking(
        id: 'BK-1010',
        userId: userId,
        userName: demoUser.name,
        courtId: 'court-2',
        courtName: 'Court Two',
        coachName: 'Karim Nabil',
        startsAt: DateTime(base.year, base.month, base.day + 2, 20),
        endsAt: DateTime(base.year, base.month, base.day + 2, 21),
        status: BookingStatus.pending,
        amount: 28,
        qrPayload: 'HONSET:BK-1010',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
