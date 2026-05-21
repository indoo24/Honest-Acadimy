import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

enum CourtsStatus { initial, loading, loaded, failure }

class CourtsState extends Equatable {
  const CourtsState({
    required this.status,
    required this.selectedDate,
    this.courts = const [],
    this.slotsByCourt = const {},
    this.message,
  });

  CourtsState.initial()
    : this(status: CourtsStatus.initial, selectedDate: DateTime.now());

  final CourtsStatus status;
  final DateTime selectedDate;
  final List<Court> courts;
  final Map<String, List<BookingSlot>> slotsByCourt;
  final String? message;

  CourtsState copyWith({
    CourtsStatus? status,
    DateTime? selectedDate,
    List<Court>? courts,
    Map<String, List<BookingSlot>>? slotsByCourt,
    String? message,
  }) {
    return CourtsState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      courts: courts ?? this.courts,
      slotsByCourt: slotsByCourt ?? this.slotsByCourt,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedDate,
    courts,
    slotsByCourt,
    message,
  ];
}
