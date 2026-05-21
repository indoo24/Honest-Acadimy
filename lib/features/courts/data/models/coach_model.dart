import 'package:honset_app/features/courts/domain/entities/coach.dart';

class CoachModel extends Coach {
  const CoachModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.rating,
    required super.imageUrl,
  });

  factory CoachModel.fromMap(Map<String, dynamic> map) {
    return CoachModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Club Coach',
      specialty: map['specialty'] as String? ?? 'Technique',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}
