import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
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

  Future<void> _pickDate(BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!context.mounted || picked == null) return;
    await context.read<AdminCubit>().selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin bookings'),
        actions: [
          IconButton(
            tooltip: 'Refresh day',
            onPressed: () => context.read<AdminCubit>().loadDailyOverview(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
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
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.dangerRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message ?? 'Failed to load reservations',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<AdminCubit>()
                          .loadDailyOverview(date: state.selectedDate),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final selectedDate = state.selectedDate ?? DateTime.now();

          return RefreshIndicator(
            onRefresh: () => context
                .read<AdminCubit>()
                .loadDailyOverview(date: state.selectedDate),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _AdminDateSelector(
                  selectedDate: selectedDate,
                  onPickDate: () => _pickDate(context, selectedDate),
                  onSelectDate: (date) => context.read<AdminCubit>().selectDate(date),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'Confirmed reservations',
                  subtitle: state.selectedDateLabel,
                  icon: Icons.verified_rounded,
                ),
                const SizedBox(height: 12),
                if (state.hasConfirmedBookings)
                  ...state.confirmedBookings.map(
                    (booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(booking: booking),
                    ),
                  )
                else if (state.hasBookings)
                  const _EmptySectionMessage(message: 'No confirmed reservations')
                else
                  const EmptyState(
                    icon: Icons.event_busy_rounded,
                    title: 'No reservations on this day',
                    message: '',
                  ),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Pending confirmations',
                  subtitle: 'Awaiting admin review',
                  icon: Icons.pending_actions_rounded,
                ),
                const SizedBox(height: 12),
                if (state.hasPendingBookings)
                  ...state.pendingBookings.map(
                    (booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(
                        booking: booking,
                        showActions: true,
                      ),
                    ),
                  )
                else if (state.hasBookings)
                  const _EmptySectionMessage(
                    message: 'No pending confirmations',
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminDateSelector extends StatelessWidget {
  const _AdminDateSelector({
    required this.selectedDate,
    required this.onPickDate,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final ValueChanged<DateTime> onSelectDate;

  List<DateTime> _buildWindow() {
    return List.generate(
      9,
      (index) => selectedDate.dateOnly.add(Duration(days: index - 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildWindow();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.squashGreen.withValues(alpha: 0.12),
            AppColors.rallyOrange.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily reservations',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedDate.readableDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Pick date'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day.isSameDate(selectedDate);
                return _DatePill(
                  date: day,
                  isSelected: isSelected,
                  onTap: () => onSelectDate(day),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.squashGreen
        : Theme.of(context).colorScheme.surface;
    final foregroundColor = isSelected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.squashGreen
                : Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.shortDay.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              date.dayNumber,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    this.showActions = false,
  });

  final Booking booking;
  final bool showActions;

  String _statusLabel() {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending_payment:
        return 'Pending payment';
      case BookingStatus.pending_payment_review:
        return 'Pending review';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _paymentStatusLabel() {
    if (booking.paymentConfirmed) return 'Paid';
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending_payment_review:
        return 'Payment under review';
      case BookingStatus.pending_payment:
        return 'Awaiting payment';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor() {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.squashGreen;
      case BookingStatus.pending_payment:
      case BookingStatus.pending_payment_review:
        return AppColors.rallyOrange;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return AppColors.dangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${booking.startsAt.timeLabel} - ${booking.endsAt.timeLabel}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coach: ${booking.coachName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: _statusLabel(),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailChip(
                  icon: Icons.receipt_long_rounded,
                  label: 'Payment: ${_paymentStatusLabel()}',
                  color: statusColor,
                ),
                if ((booking.paymentMethod ?? '').isNotEmpty)
                  _DetailChip(
                    icon: Icons.payments_rounded,
                    label: 'Method: ${booking.paymentMethod}',
                    color: AppColors.squashGreen,
                  ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.squashGreen,
                      ),
                      onPressed: () => context.read<AdminCubit>().confirmBooking(booking.id),
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
                      onPressed: () => context.read<AdminCubit>().rejectBooking(booking.id),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Reject'),
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
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  const _EmptySectionMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.7),
            ),
      ),
    );
  }
}
