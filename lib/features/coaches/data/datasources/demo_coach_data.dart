import 'package:honset_app/features/coaches/domain/entities/coach_availability_slot.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';

class DemoCoachData {
  const DemoCoachData._();

  static final DateTime _baseDate = DateTime.now();

  static List<CoachAvailabilitySlot> _slots({required int startHour}) {
    return [
      CoachAvailabilitySlot(
        startsAt: DateTime(
          _baseDate.year,
          _baseDate.month,
          _baseDate.day,
          startHour,
        ),
        endsAt: DateTime(
          _baseDate.year,
          _baseDate.month,
          _baseDate.day,
          startHour + 1,
        ),
        status: CoachSlotStatus.available,
        courtId: 'court-1',
      ),
      CoachAvailabilitySlot(
        startsAt: DateTime(
          _baseDate.year,
          _baseDate.month,
          _baseDate.day,
          startHour + 2,
        ),
        endsAt: DateTime(
          _baseDate.year,
          _baseDate.month,
          _baseDate.day,
          startHour + 3,
        ),
        status: CoachSlotStatus.reserved,
        courtId: 'court-2',
      ),
      CoachAvailabilitySlot(
        startsAt: DateTime(
          _baseDate.year,
          _baseDate.month,
          _baseDate.day,
          startHour + 4,
        ),
        endsAt: DateTime(
          _baseDate.year,
          _baseDate.month,
          _baseDate.day,
          startHour + 5,
        ),
        status: CoachSlotStatus.unavailable,
      ),
    ];
  }

  static final List<CoachProfile> coaches = [
    CoachProfile(
      id: 'coach-amira',
      name: 'Amira Hassan',
      specialty: 'Footwork and match tactics',
      yearsExperience: 9,
      bio:
          'Former national team athlete focused on elite footwork mechanics and match rhythm control.',
      rating: 4.9,
      description: 'Championship-level performance and match strategy.',
      imageUrl: 'https://i.pravatar.cc/300?img=47',
      isActive: true,
      availableSlots: _slots(startHour: 8),
      assignedCourts: ['court-1'],
    ),
    CoachProfile(
      id: 'coach-karim',
      name: 'Karim Nabil',
      specialty: 'Power play and endurance',
      yearsExperience: 11,
      bio:
          'Strength and conditioning specialist helping advanced players increase power output.',
      rating: 4.8,
      description: 'Explosive power, endurance, and tactical aggression.',
      imageUrl: 'https://i.pravatar.cc/300?img=32',
      isActive: true,
      availableSlots: _slots(startHour: 9),
      assignedCourts: ['court-2'],
    ),
    CoachProfile(
      id: 'coach-lina',
      name: 'Lina Fahmy',
      specialty: 'Junior development',
      yearsExperience: 7,
      bio:
          'Certified youth development coach focusing on fundamentals and confidence on court.',
      rating: 4.7,
      description: 'Youth training and academy onboarding.',
      imageUrl: 'https://i.pravatar.cc/300?img=49',
      isActive: true,
      availableSlots: _slots(startHour: 10),
      assignedCourts: ['court-1'],
    ),
    CoachProfile(
      id: 'coach-youssef',
      name: 'Youssef Adel',
      specialty: 'Tactical planning',
      yearsExperience: 10,
      bio:
          'Match intelligence specialist known for strategy and opponent breakdown sessions.',
      rating: 4.85,
      description: 'Tactical game plans and competitive readiness.',
      imageUrl: 'https://i.pravatar.cc/300?img=52',
      isActive: true,
      availableSlots: _slots(startHour: 11),
      assignedCourts: ['court-2'],
    ),
    CoachProfile(
      id: 'coach-sara',
      name: 'Sara Mostafa',
      specialty: 'Speed and agility',
      yearsExperience: 6,
      bio:
          'Agility coach focused on speed patterns and rapid recovery techniques.',
      rating: 4.6,
      description: 'Acceleration, agility ladders, and reaction drills.',
      imageUrl: 'https://i.pravatar.cc/300?img=31',
      isActive: true,
      availableSlots: _slots(startHour: 12),
      assignedCourts: ['court-1'],
    ),
    CoachProfile(
      id: 'coach-omar',
      name: 'Omar Khaled',
      specialty: 'Shot precision',
      yearsExperience: 8,
      bio:
          'Precision shot-making coach with a focus on accuracy and control drills.',
      rating: 4.75,
      description: 'Precision, control, and technical refinement.',
      imageUrl: 'https://i.pravatar.cc/300?img=59',
      isActive: true,
      availableSlots: _slots(startHour: 13),
      assignedCourts: ['court-2'],
    ),
    CoachProfile(
      id: 'coach-mona',
      name: 'Mona Samir',
      specialty: 'Match endurance',
      yearsExperience: 12,
      bio:
          'Endurance and stamina expert delivering high-performance conditioning plans.',
      rating: 4.9,
      description: 'Long-match endurance and recovery systems.',
      imageUrl: 'https://i.pravatar.cc/300?img=44',
      isActive: true,
      availableSlots: _slots(startHour: 14),
      assignedCourts: ['court-1', 'court-2'],
    ),
    CoachProfile(
      id: 'coach-fares',
      name: 'Fares Ismail',
      specialty: 'Competitive strategy',
      yearsExperience: 9,
      bio:
          'High-performance strategist preparing players for tournament play.',
      rating: 4.8,
      description: 'Competitive playbooks and match simulations.',
      imageUrl: 'https://i.pravatar.cc/300?img=64',
      isActive: true,
      availableSlots: _slots(startHour: 15),
      assignedCourts: ['court-2'],
    ),
    CoachProfile(
      id: 'coach-nour',
      name: 'Nour Salem',
      specialty: 'Recovery and conditioning',
      yearsExperience: 5,
      bio:
          'Recovery specialist focused on mobility, flexibility, and performance longevity.',
      rating: 4.65,
      description: 'Recovery, conditioning, and mobility plans.',
      imageUrl: 'https://i.pravatar.cc/300?img=68',
      isActive: true,
      availableSlots: _slots(startHour: 16),
      assignedCourts: ['court-1'],
    ),
  ];
}
