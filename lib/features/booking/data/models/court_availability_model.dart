import 'package:cloud_firestore/cloud_firestore.dart';

class CourtAvailabilityModel {
  final String courtId;
  final List<String> workingDays; // e.g., ["monday", "tuesday"]
  final int startHour; // 0-23
  final int endHour; // exclusive, 0-24
  final int slotDurationMinutes;
  final List<BreakPeriod> breaks;
  final bool isActive;

  CourtAvailabilityModel({
    required this.courtId,
    required this.workingDays,
    required this.startHour,
    required this.endHour,
    required this.slotDurationMinutes,
    required this.breaks,
    required this.isActive,
  });

  factory CourtAvailabilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourtAvailabilityModel(
      courtId: data['courtId'] as String,
      workingDays: List<String>.from(data['workingDays'] ?? []),
      startHour: data['startHour'] as int,
      endHour: data['endHour'] as int,
      slotDurationMinutes: data['slotDurationMinutes'] as int,
      breaks: (data['breaks'] as List<dynamic>? ?? [])
          .map((e) => BreakPeriod.fromMap(e as Map<String, dynamic>))
          .toList(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'courtId': courtId,
        'workingDays': workingDays,
        'startHour': startHour,
        'endHour': endHour,
        'slotDurationMinutes': slotDurationMinutes,
        'breaks': breaks.map((b) => b.toMap()).toList(),
        'isActive': isActive,
      };
}

class BreakPeriod {
  final int startHour;
  final int endHour;

  BreakPeriod({required this.startHour, required this.endHour});

  factory BreakPeriod.fromMap(Map<String, dynamic> map) => BreakPeriod(
        startHour: map['startHour'] as int,
        endHour: map['endHour'] as int,
      );

  Map<String, dynamic> toMap() => {
        'startHour': startHour,
        'endHour': endHour,
      };
}

