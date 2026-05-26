import 'package:equatable/equatable.dart';

import 'coach_availability_slot.dart';

class CoachProfile extends Equatable {
  const CoachProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.yearsExperience,
    required this.bio,
    required this.rating,
    required this.isActive,
    required this.availableSlots,
    required this.assignedCourts,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String name;
  final String specialty;
  final int yearsExperience;
  final String bio;
  final double rating;
  final bool isActive;
  final List<CoachAvailabilitySlot> availableSlots;
  final List<String> assignedCourts;
  final String? imageUrl;
  final String? description;

  bool get isAvailableToday => availableSlots.any((slot) => slot.isAvailable);

  @override
  List<Object?> get props => [
    id,
    name,
    specialty,
    yearsExperience,
    bio,
    rating,
    isActive,
    availableSlots,
    assignedCourts,
    imageUrl,
    description,
  ];
}
