import 'package:flutter/material.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge.slot(this.slotStatus, {super.key}) : bookingStatus = null;

  const StatusBadge.booking(this.bookingStatus, {super.key})
    : slotStatus = null;

  final SlotStatus? slotStatus;
  final BookingStatus? bookingStatus;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String get _label {
    if (slotStatus != null) return slotStatus!.name.toUpperCase();
    return bookingStatus!.name.toUpperCase();
  }

  Color get _color {
    switch (slotStatus) {
      case SlotStatus.available:
        return AppColors.squashGreen;
      case SlotStatus.reserved:
        return AppColors.dangerRed;
      case SlotStatus.pending:
        return AppColors.rallyOrange;
      case SlotStatus.past:
        return Colors.grey;
      case null:
        break;
    }
    switch (bookingStatus) {
      case BookingStatus.confirmed:
        return AppColors.squashGreen;
      case BookingStatus.pending:
        return AppColors.rallyOrange;
      case BookingStatus.cancelled:
        return AppColors.dangerRed;
      case BookingStatus.completed:
        return Colors.blueGrey;
      case null:
        return Colors.grey;
    }
  }
}
