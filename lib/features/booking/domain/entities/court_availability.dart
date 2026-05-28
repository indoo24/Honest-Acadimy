import 'package:equatable/equatable.dart';

/// Domain entity representing the scheduling rules for a single court.
class CourtAvailability extends Equatable {
  final String courtId;
  final List<String> workingDays;
  final int startHour;
  final int endHour;
  final int slotDurationMinutes;
  final List<BreakPeriod> breaks;
  final bool isActive;

  const CourtAvailability({
    required this.courtId,
    required this.workingDays,
    required this.startHour,
    required this.endHour,
    required this.slotDurationMinutes,
    required this.breaks,
    required this.isActive,
  });

  @override
  List<Object?> get props => [courtId, workingDays, startHour, endHour, slotDurationMinutes, breaks, isActive];
}

class BreakPeriod extends Equatable {
  final int startHour;
  final int endHour;

  const BreakPeriod({required this.startHour, required this.endHour});

  @override
  List<Object?> get props => [startHour, endHour];
}

