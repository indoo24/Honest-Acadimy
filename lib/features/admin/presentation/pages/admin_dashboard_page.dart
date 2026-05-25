import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminCubit>().loadDailyOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<AdminCubit>().loadDailyOverview(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookingSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add booking'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.initial ||
              state.status == AdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AdminStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.dangerRed),
                    const SizedBox(height: 16),
                    Text(
                      state.message ?? 'Failed to load data',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<AdminCubit>().loadDailyOverview(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AdminCubit>().loadDailyOverview(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Section: Today's Court Schedule ──
                _SectionHeader(
                  title: "Today's Court Schedule",
                  subtitle: state.selectedDate?.readableDate ?? '',
                  icon: Icons.calendar_view_day_rounded,
                ),
                const SizedBox(height: 16),
                ...state.courts.map(
                  (court) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _CourtScheduleColumn(
                      courtName: court.name,
                      courtId: court.id,
                      bookings: state.bookingsByCourt[court.id] ?? [],
                    ),
                  ),
                ),

                // ── Pending Actions Summary ──
                if (state.pendingCount > 0) ...[
                  const SizedBox(height: 8),
                  _PendingSummary(pendingCount: state.pendingCount),
                  const SizedBox(height: 16),
                ] else
                  const SizedBox(height: 8),

                // ── Section: Coach Schedules ──
                const Divider(height: 32),
                _SectionHeader(
                  title: 'Coach Schedules',
                  subtitle: 'Today\u2019s reservations by coach',
                  icon: Icons.sports_rounded,
                ),
                const SizedBox(height: 16),
                if (state.coaches.isEmpty)
                  const EmptyState(
                    icon: Icons.group_outlined,
                    title: 'No coaches available',
                    message: '',
                  )
                else
                  ...state.coaches.map(
                    (coach) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CoachScheduleCard(
                        coach: coach,
                        bookings: state.bookingsByCoach[coach.id] ?? [],
                      ),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddBookingSheet(BuildContext context) {
    final courts = context.read<AdminCubit>().state.courts;
    final coaches = context.read<AdminCubit>().state.coaches;
    var selectedCourtId = courts.isNotEmpty ? courts.first.id : '';
    var selectedCoachId = coaches.isNotEmpty ? coaches.first.id : '';
    var selectedDate = DateTime.now();
    var selectedHour = 18;
    final bookedByUserId = context.read<AuthCubit>().state.user?.id;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual booking',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedCourtId.isEmpty ? null : selectedCourtId,
                      decoration: const InputDecoration(
                        labelText: 'Court',
                        prefixIcon: Icon(Icons.sports_tennis_rounded),
                      ),
                      items: [
                        for (final court in courts)
                          DropdownMenuItem(
                            value: court.id,
                            child: Text(court.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedCourtId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedCoachId.isEmpty ? null : selectedCoachId,
                      decoration: const InputDecoration(
                        labelText: 'Coach',
                        prefixIcon: Icon(Icons.sports_rounded),
                      ),
                      items: [
                        for (final coach in coaches)
                          DropdownMenuItem(
                            value: coach.id,
                            child: Text(coach.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedCoachId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(const Duration(days: 45)),
                                initialDate: selectedDate,
                              );
                              if (!context.mounted || picked == null) return;
                              setModalState(() => selectedDate = picked);
                            },
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: Text(selectedDate.readableDate),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 132,
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedHour,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                            ),
                            items: [
                              for (var hour = 7; hour < 23; hour++)
                                DropdownMenuItem(
                                  value: hour,
                                  child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setModalState(() => selectedHour = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed:
                          selectedCourtId.isEmpty || selectedCoachId.isEmpty
                              ? null
                              : () {
                                  final coach = coaches.firstWhere(
                                    (item) => item.id == selectedCoachId,
                                    orElse: () => coaches.first,
                                  );
                                  context.read<AdminCubit>().addManualBooking(
                                        courtId: selectedCourtId,
                                        coachId: coach.id,
                                        coachName: coach.name,
                                        date: selectedDate,
                                        hour: selectedHour,
                                        bookedByUserId: bookedByUserId,
                                      );
                                  Navigator.pop(context);
                                },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create booking'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Section Header Widget ──

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.squashGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.squashGreen, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Court Schedule Column ──

class _CourtScheduleColumn extends StatelessWidget {
  const _CourtScheduleColumn({
    required this.courtName,
    required this.courtId,
    required this.bookings,
  });

  final String courtName;
  final String courtId;
  final List<Booking> bookings;

  /// Generate all time slots from 7:00 to 22:00 and merge with bookings.
  List<_SlotItem> _buildSlots() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slots = <_SlotItem>[];

    for (var hour = 7; hour < 22; hour++) {
      final slotStart = today.add(Duration(hours: hour));
      final isPast = slotStart.isBefore(now);

      // Check if any booking matches this time slot
      final booking = bookings.cast<Booking?>().firstWhere(
            (b) => b!.startsAt.hour == hour,
            orElse: () => null,
          );

      if (booking != null) {
        slots.add(_SlotItem(
          time: '${hour.toString().padLeft(2, '0')}:00',
          status: _SlotDisplayStatus.fromBookingStatus(
            booking.status,
            isPast,
          ),
          coachName: booking.coachName,
          bookingId: booking.id,
          isPast: isPast,
        ));
      } else {
        slots.add(_SlotItem(
          time: '${hour.toString().padLeft(2, '0')}:00',
          status: isPast ? _SlotDisplayStatus.past : _SlotDisplayStatus.available,
          coachName: null,
          bookingId: null,
          isPast: isPast,
        ));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _buildSlots();
    final pendingSlots =
        slots.where((s) => s.status == _SlotDisplayStatus.pending).toList();
    final hasPending = pendingSlots.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasPending
              ? AppColors.rallyOrange.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Court header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.squashGreen.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_tennis_rounded,
                    color: AppColors.squashGreen, size: 20),
                const SizedBox(width: 10),
                Text(
                  courtName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  '${slots.length} slots',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          // Slot list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: slots.map((slot) {
                return _SlotCard(
                  slot: slot,
                  courtName: courtName,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slot Display Status ──

enum _SlotDisplayStatus {
  available,
  pending,
  confirmed,
  past;

  static _SlotDisplayStatus fromBookingStatus(
      BookingStatus status, bool isPast) {
    if (isPast) return past;
    switch (status) {
      case BookingStatus.pending:
        return pending;
      case BookingStatus.confirmed:
        return confirmed;
      case BookingStatus.cancelled:
        return available;
      case BookingStatus.completed:
        return past;
    }
  }

  Color get color {
    switch (this) {
      case _SlotDisplayStatus.available:
        return AppColors.squashGreen;
      case _SlotDisplayStatus.pending:
        return AppColors.rallyOrange;
      case _SlotDisplayStatus.confirmed:
        return AppColors.dangerRed;
      case _SlotDisplayStatus.past:
        return Colors.grey;
    }
  }

  String get label {
    switch (this) {
      case _SlotDisplayStatus.available:
        return 'Available';
      case _SlotDisplayStatus.pending:
        return 'Pending';
      case _SlotDisplayStatus.confirmed:
        return 'Confirmed';
      case _SlotDisplayStatus.past:
        return 'Past';
    }
  }
}

// ── Slot Item Data ──

class _SlotItem {
  const _SlotItem({
    required this.time,
    required this.status,
    this.coachName,
    this.bookingId,
    required this.isPast,
  });

  final String time;
  final _SlotDisplayStatus status;
  final String? coachName;
  final String? bookingId;
  final bool isPast;
}

// ── Individual Slot Card ──

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.courtName,
  });

  final _SlotItem slot;
  final String courtName;

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.status == _SlotDisplayStatus.confirmed ||
        slot.status == _SlotDisplayStatus.pending;
    final statusColor = slot.status.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: statusColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: slot.isPast || slot.status == _SlotDisplayStatus.available
              ? null
              : () => _showBookingActions(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                // Time column
                SizedBox(
                  width: 56,
                  child: Text(
                    slot.time,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ),
                // Status indicator dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                // Slot info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _StatusChip(
                            label: slot.status.label,
                            color: statusColor,
                          ),
                          if (isBooked && slot.coachName != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                slot.coachName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons for pending/confirmed slots
                if (slot.status == _SlotDisplayStatus.pending) ...[
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    color: AppColors.squashGreen,
                    tooltip: 'Confirm',
                    onPressed: () => _confirmBooking(context),
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.cancel_outlined,
                    color: AppColors.dangerRed,
                    tooltip: 'Reject',
                    onPressed: () => _rejectBooking(context),
                  ),
                ],
                if (slot.status == _SlotDisplayStatus.confirmed)
                  _ActionButton(
                    icon: Icons.cancel_outlined,
                    color: AppColors.dangerRed.withValues(alpha: 0.6),
                    tooltip: 'Free up slot',
                    onPressed: () => _cancelBooking(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmBooking(BuildContext context) {
    if (slot.bookingId == null) return;
    context.read<AdminCubit>().confirmBooking(slot.bookingId!);
  }

  void _rejectBooking(BuildContext context) {
    if (slot.bookingId == null) return;
    context.read<AdminCubit>().rejectBooking(slot.bookingId!);
  }

  void _cancelBooking(BuildContext context) {
    if (slot.bookingId == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Free up this slot?'),
        content: Text(
            'Cancel ${slot.coachName ?? "the coach"}\'s booking at ${slot.time} on $courtName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
            ),
            onPressed: () {
              context.read<AdminCubit>().cancelBooking(slot.bookingId!);
              Navigator.pop(ctx);
            },
            child: const Text('Free up'),
          ),
        ],
      ),
    );
  }

  void _showBookingActions(BuildContext context) {
    if (slot.bookingId == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slot.time} \u2022 $courtName',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (slot.coachName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Booked by: ${slot.coachName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            _StatusChip(label: slot.status.label, color: slot.status.color),
            const SizedBox(height: 20),
            if (slot.status == _SlotDisplayStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.squashGreen,
                      ),
                      onPressed: () {
                        _confirmBooking(context);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerRed,
                        side: const BorderSide(color: AppColors.dangerRed),
                      ),
                      onPressed: () {
                        _rejectBooking(context);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
            if (slot.status == _SlotDisplayStatus.confirmed) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerRed,
                    side: const BorderSide(color: AppColors.dangerRed),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cancelBooking(context);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Free up this slot'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Status Chip ──

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
      ),
    );
  }
}

// ── Action Button ──

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

// ── Pending Summary Banner ──

class _PendingSummary extends StatelessWidget {
  const _PendingSummary({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.rallyOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rallyOrange.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.rallyOrange, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$pendingCount pending ${pendingCount == 1 ? 'booking' : 'bookings'} need your review',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach Schedule Card ──

class _CoachScheduleCard extends StatelessWidget {
  const _CoachScheduleCard({
    required this.coach,
    required this.bookings,
  });

  final CoachProfile coach;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coach avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.squashGreen.withValues(alpha: 0.12),
              backgroundImage:
                  coach.imageUrl != null ? NetworkImage(coach.imageUrl!) : null,
              child: coach.imageUrl == null
                  ? Text(
                      coach.name.isNotEmpty
                          ? coach.name[0].toUpperCase()
                          : '?',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (coach.specialty.isNotEmpty)
                    Text(
                      coach.specialty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.6),
                          ),
                    ),
                  if (bookings.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'No reservations today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    ...bookings.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: booking.status == BookingStatus.confirmed
                                    ? AppColors.squashGreen.withValues(alpha: 0.1)
                                    : AppColors.rallyOrange
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                booking.startsAt.timeLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking.courtName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusBgColor(booking.status),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                booking.status.name.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: _statusTextColor(booking.status),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBgColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.rallyOrange.withValues(alpha: 0.15);
      case BookingStatus.confirmed:
        return AppColors.squashGreen.withValues(alpha: 0.15);
      case BookingStatus.cancelled:
        return Colors.grey.withValues(alpha: 0.15);
      case BookingStatus.completed:
        return Colors.blueGrey.withValues(alpha: 0.15);
    }
  }

  Color _statusTextColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.rallyOrange;
      case BookingStatus.confirmed:
        return AppColors.squashGreen;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.completed:
        return Colors.blueGrey;
    }
  }
}