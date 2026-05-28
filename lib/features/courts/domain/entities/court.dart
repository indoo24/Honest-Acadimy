import 'package:equatable/equatable.dart';

class Court extends Equatable {
  const Court({
    required this.id,
    required this.name,
    required this.isActive,
    required this.pricePerHour,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String name;
  final bool isActive;
  final double pricePerHour;
  final String? imageUrl;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    name,
    isActive,
    pricePerHour,
    imageUrl,
    description,
  ];
}
