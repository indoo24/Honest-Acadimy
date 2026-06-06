import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_availability_slot.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';

class CoachProfileModel extends CoachProfile {
  const CoachProfileModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.yearsExperience,
    required super.bio,
    required super.rating,
    required super.isActive,
    required super.availableSlots,
    required super.assignedCourts,
    required super.weeklyAvailability,
    super.imageUrl,
    super.description,
  });

  factory CoachProfileModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final slots = (map['availableSlots'] as List? ?? [])
        .map((slot) => _slotFromMap(Map<String, dynamic>.from(slot as Map)))
        .toList();
    final weeklyAvailability = _weeklyAvailabilityFromMap(
      map['weeklyAvailability'] as Map<String, dynamic>?,
    );
    return CoachProfileModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Squash Coach',
      imageUrl: map['imageUrl'] as String?,
      specialty: map['specialty'] as String? ?? 'Elite training',
      yearsExperience: (map['yearsExperience'] as num?)?.toInt() ?? 6,
      bio: map['bio'] as String? ?? 'Certified squash performance coach.',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      isActive: map['isActive'] as bool? ?? true,
      availableSlots: slots,
      assignedCourts: (map['assignedCourts'] as List? ?? []).cast<String>(),
      weeklyAvailability: weeklyAvailability,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'specialty': specialty,
      'yearsExperience': yearsExperience,
      'bio': bio,
      'rating': rating,
      'isActive': isActive,
      'availableSlots': availableSlots.map(_slotToMap).toList(),
      'assignedCourts': assignedCourts,
      'weeklyAvailability': weeklyAvailability.map(
        (key, value) => MapEntry(key, _weeklyAvailabilityToMap(value)),
      ),
      'description': description,
    };
  }

  static CoachAvailabilitySlot _slotFromMap(Map<String, dynamic> map) {
    final status = map['status'] as String? ?? 'available';
    return CoachAvailabilitySlot(
      startsAt: (map['startsAt'] is Timestamp)
          ? (map['startsAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['startsAt']?.toString() ?? '') ??
                DateTime.now(),
      endsAt: (map['endsAt'] is Timestamp)
          ? (map['endsAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['endsAt']?.toString() ?? '') ??
                DateTime.now(),
      status: CoachSlotStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => CoachSlotStatus.available,
      ),
      courtId: map['courtId'] as String?,
    );
  }

  static Map<String, dynamic> _slotToMap(CoachAvailabilitySlot slot) {
    return {
      'startsAt': Timestamp.fromDate(slot.startsAt),
      'endsAt': Timestamp.fromDate(slot.endsAt),
      'status': slot.status.name,
      'courtId': slot.courtId,
    };
  }

  static Map<String, WeeklyAvailabilityRange> _weeklyAvailabilityFromMap(
    Map<String, dynamic>? map,
  ) {
    if (map == null) return const {};
    final availability = <String, WeeklyAvailabilityRange>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is! Map) continue;
      final dayMap = Map<String, dynamic>.from(value);
      availability[entry.key] = WeeklyAvailabilityRange(
        startHour: (dayMap['startHour'] as num?)?.toInt() ?? 0,
        endHour: (dayMap['endHour'] as num?)?.toInt() ?? 0,
      );
    }
    return availability;
  }

  static Map<String, dynamic> _weeklyAvailabilityToMap(
    WeeklyAvailabilityRange range,
  ) {
    return {'startHour': range.startHour, 'endHour': range.endHour};
  }
}
