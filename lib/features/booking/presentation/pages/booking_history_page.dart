import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/courts/presentation/cubit/court_details_cubit.dart';
import 'package:honset_app/features/courts/presentation/cubit/court_details_state.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/status_badge.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthCubit>().state.user;
      context.read<BookingCubit>().loadHistory(user?.id ?? 'guest');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking history')),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state.status == BookingActionStatus.success &&
              state.lastAction == BookingLastAction.cancel) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking cancelled successfully')),
            );
          } else if (state.status == BookingActionStatus.success &&
              state.lastAction == BookingLastAction.reschedule) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking rescheduled successfully')),
            );
          } else if (state.status == BookingActionStatus.failure &&
              (state.lastAction == BookingLastAction.cancel ||
                  state.lastAction == BookingLastAction.reschedule)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Operation failed')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BookingActionStatus.loading &&
              state.lastAction == BookingLastAction.none) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.history.isEmpty) {
            return const EmptyState(
              icon: Icons.confirmation_number_outlined,
              title: 'No bookings yet',
              message:
                  'Your confirmed and pending reservations will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = state.history[index];
              debugPrint(
                '[BOOKING HISTORY READ]\ncoachId=${booking.coachId}\ncoachName=${booking.coachName}',
              );
              return _BookingCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Card with Cancel / Edit Time actions
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  bool get _isActive =>
      booking.status == BookingStatus.pendingPayment ||
      booking.status == BookingStatus.pendingPaymentReview ||
      booking.status == BookingStatus.confirmed;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select<BookingCubit, bool>((c) => c.state.status == BookingActionStatus.loading);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_tennis_rounded,
                    color: AppColors.electricBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.startsAt.readableDate} • ${booking.startsAt.timeLabel} – ${booking.endsAt.timeLabel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.subtitleGray,
                            ),
                      ),
                    ],
                  ),
                ),
                StatusBadge.booking(booking.status),
              ],
            ),

            // ── Coach name ──
            if (booking.coachName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 16, color: AppColors.subtitleGray),
                  const SizedBox(width: 6),
                  Text(
                    'Coach: ${booking.coachName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subtitleGray,
                        ),
                  ),
                ],
              ),
            ],

            // ── Action buttons (only for active bookings) ──
            if (_isActive) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _showCancelDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerRed,
                        side: const BorderSide(color: AppColors.dangerRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Edit Time button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _showRescheduleSheet(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.electricBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                      label: const Text('Edit Time',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cancel Booking'),
          content: Text(
            'Are you sure you want to cancel your booking for '
            '${booking.courtName} at ${booking.startsAt.timeLabel}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
              ),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<BookingCubit>().cancelBooking(
              bookingId: booking.id,
              coachName: booking.coachName,
            );
      }
    });
  }

  void _showRescheduleSheet(BuildContext context) {
    final bookingCubit = context.read<BookingCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bookingCubit,
          child: _RescheduleSheet(booking: booking),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reschedule Bottom Sheet — loads slots and lets coach pick a new time
// ─────────────────────────────────────────────────────────────────────────────

class _RescheduleSheet extends StatefulWidget {
  const _RescheduleSheet({required this.booking});

  final Booking booking;

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  late CourtDetailsCubit _slotCubit;
  BookingSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    final dateOnly = DateTime(
      widget.booking.startsAt.year,
      widget.booking.startsAt.month,
      widget.booking.startsAt.day,
    );
    _slotCubit = CourtDetailsCubit(
      court: Court(
        id: widget.booking.courtId,
        name: widget.booking.courtName,
        isActive: true,
        pricePerHour: widget.booking.amount / 0.75, // reverse from 45-min price
      ),
      selectedDate: dateOnly,
      bookingDataSource: getIt<FirestoreBookingDataSource>(),
      availabilityRepository: getIt<CourtAvailabilityRepository>(),
    )..loadBookingsForDate();
  }

  @override
  void dispose() {
    _slotCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _slotCubit,
      child: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state.status == BookingActionStatus.success &&
              state.lastAction == BookingLastAction.reschedule) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title ──
                Text(
                  'Reschedule Booking',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.booking.courtName} • ${widget.booking.startsAt.readableDate}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleGray,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 16, color: AppColors.dangerRed),
                      const SizedBox(width: 6),
                      Text(
                        'Current: ${widget.booking.startsAt.timeLabel} – ${widget.booking.endsAt.timeLabel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.dangerRed,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Select new time slot',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),

                // ── Slot grid ──
                BlocBuilder<CourtDetailsCubit, CourtDetailsState>(
                  builder: (context, state) {
                    if (state.status == CourtDetailsStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.status == CourtDetailsStatus.failure) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          state.errorMessage ?? 'Failed to load slots.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.dangerRed),
                        ),
                      );
                    }
                    if (state.generatedSlots.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No available slots for this date.'),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: state.generatedSlots.length,
                      itemBuilder: (context, index) {
                        final slot = state.generatedSlots[index];
                        final isCurrentSlot =
                            slot.startsAt == widget.booking.startsAt &&
                                slot.endsAt == widget.booking.endsAt;
                        final isSelected = _selectedSlot?.id == slot.id;

                        return _RescheduleSlotTile(
                          slot: slot,
                          isSelected: isSelected,
                          isCurrentSlot: isCurrentSlot,
                          onTap: () {
                            if (slot.canBook && !isCurrentSlot) {
                              setState(() => _selectedSlot = slot);
                            }
                          },
                        );
                      },
                    );
                  },
                ),

                // ── Confirm button ──
                const SizedBox(height: 20),
                BlocSelector<BookingCubit, BookingState, bool>(
                  selector: (state) =>
                      state.status == BookingActionStatus.loading &&
                      state.lastAction == BookingLastAction.reschedule,
                  builder: (context, isLoading) {
                    return FilledButton.icon(
                      onPressed: _selectedSlot == null || isLoading
                          ? null
                          : () {
                              context.read<BookingCubit>().rescheduleBooking(
                                    bookingId: widget.booking.id,
                                    coachName: widget.booking.coachName,
                                    newStart: _selectedSlot!.startsAt,
                                    newEnd: _selectedSlot!.endsAt,
                                  );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.electricBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: isLoading
                            ? const SizedBox.square(
                                key: ValueKey('loading'),
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_rounded,
                                key: ValueKey('icon')),
                      ),
                      label: Text(
                        isLoading
                            ? 'Rescheduling...'
                            : _selectedSlot == null
                                ? 'Select a new time'
                                : 'Confirm ${_selectedSlot!.startsAt.timeLabel} – ${_selectedSlot!.endsAt.timeLabel}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reschedule Slot Tile
// ─────────────────────────────────────────────────────────────────────────────

class _RescheduleSlotTile extends StatelessWidget {
  const _RescheduleSlotTile({
    required this.slot,
    required this.isSelected,
    required this.isCurrentSlot,
    required this.onTap,
  });

  final BookingSlot slot;
  final bool isSelected;
  final bool isCurrentSlot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.canBook && !isCurrentSlot;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCurrentSlot) {
      backgroundColor = AppColors.dangerRed.withValues(alpha: 0.08);
      borderColor = AppColors.dangerRed.withValues(alpha: 0.3);
      textColor = AppColors.dangerRed;
    } else if (isSelected) {
      backgroundColor = AppColors.electricBlue.withValues(alpha: 0.15);
      borderColor = AppColors.electricBlue;
      textColor = AppColors.electricBlue;
    } else if (!slot.canBook) {
      backgroundColor = Theme.of(context).dividerColor.withValues(alpha: 0.05);
      borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.1);
      textColor = Theme.of(context).disabledColor;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surface;
      borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.2);
      textColor =
          Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.startsAt.timeLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
              ),
              if (isCurrentSlot)
                Text(
                  'Current',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.dangerRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                )
              else if (!slot.canBook)
                Text(
                  'Unavailable',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontSize: 10,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
