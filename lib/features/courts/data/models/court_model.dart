import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honset_app/features/courts/data/models/coach_model.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class CourtModel extends Court {
  const CourtModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.surface,
    required super.hourlyRate,
    required super.isActive,
    required super.coach,
  });

  factory CourtModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final surface = data['surface'] as String? ?? 'glassBack';
    return CourtModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Squash Court',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      surface: CourtSurface.values.firstWhere(
        (value) => value.name == surface,
        orElse: () => CourtSurface.glassBack,
      ),
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      coach: CoachModel.fromMap(
        Map<String, dynamic>.from(data['coach'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'surface': surface.name,
      'hourlyRate': hourlyRate,
      'isActive': isActive,
      'coach': CoachModel(
        id: coach.id,
        name: coach.name,
        specialty: coach.specialty,
        rating: coach.rating,
        imageUrl: coach.imageUrl,
      ).toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
