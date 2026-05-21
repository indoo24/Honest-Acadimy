import 'package:equatable/equatable.dart';
import 'package:honset_app/features/courts/domain/entities/coach.dart';

enum CourtSurface { glassBack, traditional }

class Court extends Equatable {
  const Court({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.surface,
    required this.hourlyRate,
    required this.isActive,
    required this.coach,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final CourtSurface surface;
  final double hourlyRate;
  final bool isActive;
  final Coach coach;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    surface,
    hourlyRate,
    isActive,
    coach,
  ];
}
