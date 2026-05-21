import 'package:equatable/equatable.dart';

class Coach extends Equatable {
  const Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String imageUrl;

  @override
  List<Object?> get props => [id, name, specialty, rating, imageUrl];
}
