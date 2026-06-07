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
    final raw = doc.data();
    if (raw is! Map<String, dynamic>) {
      throw StateError('courtAvailability/${doc.id} has no data');
    }
    final data = raw;
    return CourtAvailabilityModel(
      courtId: data['courtId'] as String? ?? '',
      workingDays: List<String>.from(data['workingDays'] as List? ?? const []),
      startHour: (data['startHour'] as num?)?.toInt() ?? 0,
      endHour: (data['endHour'] as num?)?.toInt() ?? 0,
      slotDurationMinutes: (data['slotDurationMinutes'] as num?)?.toInt() ?? 60,
      breaks: (data['breaks'] as List<dynamic>? ?? const [])
          .map((e) => BreakPeriod.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }
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

