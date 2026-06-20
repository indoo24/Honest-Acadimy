import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/presentation/cubit/coaches_cubit.dart';
import 'package:honset_app/features/courts/presentation/cubit/court_details_cubit.dart';
import 'package:honset_app/features/courts/presentation/cubit/court_details_state.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_cubit.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';

class CourtDetailsPage extends StatelessWidget {
  const CourtDetailsPage({super.key, required this.args});

  final CourtDetailsArgs? args;

  @override
  Widget build(BuildContext context) {
    final resolvedArgs = args;
    if (resolvedArgs == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.sports_tennis_rounded,
          title: 'Court not selected',
          message: 'Return to the booking dashboard and choose a court.',
        ),
      );
    }

    final selectedDate = resolvedArgs.selectedDate ??
        (resolvedArgs.slots.isNotEmpty
            ? resolvedArgs.slots.first.startsAt
            : DateTime.now());
    final dateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    return BlocProvider(
      create: (_) => CourtDetailsCubit(
        court: resolvedArgs.court,
        selectedDate: dateOnly,
        bookingDataSource: getIt<FirestoreBookingDataSource>(),
        availabilityRepository: getIt<CourtAvailabilityRepository>(),
      )..loadBookingsForDate(),
      child: _CourtDetailsView(args: resolvedArgs),
    );
  }
}

class _CourtDetailsView extends StatelessWidget {
  const _CourtDetailsView({required this.args});

  final CourtDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final court = args.court;

    return Scaffold(
      appBar: AppBar(title: Text(court.name)),
      body: BlocBuilder<CourtDetailsCubit, CourtDetailsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── Hero Banner ──
              SliverToBoxAdapter(
                child: AspectRatio(
                  aspectRatio:
                      MediaQuery.sizeOf(context).width < 600 ? 1.45 : 2.8,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.squashGreen.withValues(alpha: 0.3),
                              AppColors.clubNavy.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sports_tennis_rounded,
                            size: 80,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: .58),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              court.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (court.description != null &&
                                court.description!.isNotEmpty)
                              Text(
                                court.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: .82),
                                    ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${court.pricePerHour.toStringAsFixed(0)} / hour',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: .9),
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ──
              SliverPadding(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
                ),
                sliver: SliverList.list(
                  children: [
                    // ── Loading / Error ──
                    if (state.status == CourtDetailsStatus.loading) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                    ],
                    if (state.status == CourtDetailsStatus.failure) ...[
                      const SizedBox(height: 10),
                      Text(
                        state.errorMessage ?? 'Failed to load bookings.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.dangerRed,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Booked Times ──
                    const SizedBox(height: 8),
                    Text(
                      'Booked times',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    _BookedTimesList(bookings: state.activeBookings),

                    // ── Time Slots ──
                    const SizedBox(height: 24),
                    Text(
                      'Select your booking time',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    if (state.generatedSlots.isEmpty && state.status == CourtDetailsStatus.loaded)
                      const Text('No slots available for this date.'),
                    if (state.generatedSlots.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: state.generatedSlots.length,
                        itemBuilder: (context, index) {
                          final slot = state.generatedSlots[index];
                          final isSelected = state.selectedSlot?.id == slot.id;
                          return _SlotTile(
                            slot: slot,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<CourtDetailsCubit>().selectSlot(slot);
                            },
                          );
                        },
                      ),

                    // ── Price Summary ──
                    if (state.canBook) ...[
                      const SizedBox(height: 16),
                      _PriceSummary(
                        durationMinutes: 45,
                        totalPrice: state.totalPrice,
                        pricePerHour: court.pricePerHour,
                      ),
                    ],

                    // ── Book Button ──
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: state.canBook
                          ? () => _showBookingSheet(context)
                          : null,
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text(
                        state.selectedSlot == null
                            ? 'Select a time slot'
                            : 'Book ${state.selectedSlot!.startsAt.timeLabel} – ${state.selectedSlot!.endsAt.timeLabel}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Future<void> _showBookingSheet(BuildContext context) async {
    final cubit = context.read<CourtDetailsCubit>();
    final slot = cubit.state.selectedSlot;
    if (slot == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return _BookingSheet(
          parentContext: context,
          args: args,
          slot: slot,
          totalPrice: cubit.state.totalPrice,
        );
      },
    );
    if (context.mounted) {
      cubit.loadBookingsForDate();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BookedTimesList extends StatelessWidget {
  const _BookedTimesList({required this.bookings});

  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.squashGreen.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.squashGreen.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.squashGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'No bookings yet — all times available!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.squashGreen,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final booking in bookings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BookedTimeCard(booking: booking),
          ),
      ],
    );
  }
}

class _BookedTimeCard extends StatelessWidget {
  const _BookedTimeCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final statusColor = booking.status == BookingStatus.confirmed
        ? AppColors.dangerRed
        : AppColors.rallyOrange;
    final statusLabel = booking.status == BookingStatus.confirmed
        ? 'Confirmed'
        : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.startsAt.timeLabel} – ${booking.endsAt.timeLabel}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                ),
                if (booking.coachName.isNotEmpty)
                  Text(
                    'Coach: ${booking.coachName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final BookingSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.canBook;
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (isSelected) {
      backgroundColor = AppColors.squashGreen.withValues(alpha: 0.15);
      borderColor = AppColors.squashGreen;
      textColor = AppColors.squashGreen;
    } else if (!isAvailable) {
      backgroundColor = Theme.of(context).dividerColor.withValues(alpha: 0.05);
      borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.1);
      textColor = Theme.of(context).disabledColor;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surface;
      borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.2);
      textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
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
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
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
              if (!isAvailable)
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

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.durationMinutes,
    required this.totalPrice,
    required this.pricePerHour,
  });

  final int durationMinutes;
  final double totalPrice;
  final double pricePerHour;

  @override
  Widget build(BuildContext context) {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    final durationLabel = hours > 0 && minutes > 0
        ? '${hours}h ${minutes}m'
        : hours > 0
            ? '${hours}h'
            : '${minutes}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.squashGreen.withValues(alpha: 0.08),
            AppColors.squashGreen.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.squashGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                durationLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rate', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '\$${pricePerHour.toStringAsFixed(0)} / hour',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.squashGreen,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Sheet (Coach selection + confirm — mostly preserved from original)
// ─────────────────────────────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.parentContext,
    required this.args,
    required this.slot,
    required this.totalPrice,
  });

  final BuildContext parentContext;
  final CourtDetailsArgs args;
  final dynamic slot; // BookingSlot
  final double totalPrice;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String? _selectedCoachId;
  CoachProfile? _selectedCoach;

  CoachProfile? _findCoachById(List<CoachProfile> coaches, String? coachId) {
    if (coachId == null) return null;
    for (final coach in coaches) {
      if (coach.id == coachId) return coach;
    }
    return null;
  }

  void _reportInvalidCoachSelection({
    required String? selectedCoachId,
    required List<CoachProfile> coaches,
  }) {
    final availableIds = coaches.map((coach) => coach.id).join(', ');
    debugPrint(
      '[COACH SELECTION ERROR] selectedCoachId=$selectedCoachId not found in coaches=[$availableIds]',
    );
    assert(() {
      throw FlutterError(
        'Selected coach id "$selectedCoachId" is missing from dropdown data.',
      );
    }());
  }

  @override
  void initState() {
    super.initState();
    final coachesCubit = widget.parentContext.read<CoachesCubit>();
    coachesCubit.watchCoaches();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state.status == BookingActionStatus.success) {
          if (mounted) {
            Navigator.of(context).pop();
          }
          if (!widget.parentContext.mounted) return;
          ScaffoldMessenger.of(
            widget.parentContext,
          ).showSnackBar(const SnackBar(content: Text('Booking created')));
          widget.parentContext.read<CourtsCubit>().loadDashboard();
        } else if (state.status == BookingActionStatus.failure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Booking failed')),
          );
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
              Text(
                'Reserve court',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.args.court.name} • ${DateFormat('h:mm a').format(widget.slot.startsAt)} – ${DateFormat('h:mm a').format(widget.slot.endsAt)}',
              ),
              const SizedBox(height: 6),
              Text(
                'Total: \$${widget.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.squashGreen,
                    ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CoachesCubit, CoachesState>(
                builder: (context, state) {
                  final coaches = state.coaches;
                  final selectedCoach = _selectedCoach == null
                      ? null
                      : _findCoachById(coaches, _selectedCoach!.id);
                  if (_selectedCoachId != null && selectedCoach == null) {
                    _reportInvalidCoachSelection(
                      selectedCoachId: _selectedCoachId,
                      coaches: coaches,
                    );
                  }
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(
                        'coach-dropdown-${_selectedCoachId ?? 'none'}-${coaches.length}',
                      ),
                      initialValue: selectedCoach?.id,
                      decoration: const InputDecoration(
                        labelText: 'Coach',
                        prefixIcon: Icon(Icons.sports_rounded),
                      ),
                      items: [
                        for (final coach in coaches)
                          DropdownMenuItem(
                            value: coach.id,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundImage:
                                      coach.imageUrl?.isNotEmpty == true
                                          ? NetworkImage(coach.imageUrl!)
                                          : null,
                                  child: coach.imageUrl?.isNotEmpty == true
                                      ? null
                                      : const Icon(Icons.person, size: 14),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    coach.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${coach.yearsExperience}y',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: state.status == CoachesStatus.loading
                          ? null
                          : (value) {
                              final match = _findCoachById(coaches, value);
                              if (match == null) {
                                _reportInvalidCoachSelection(
                                  selectedCoachId: value,
                                  coaches: coaches,
                                );
                                return;
                              }
                              debugPrint('SELECTED COACH ID: ${match.id}');
                              debugPrint('SELECTED COACH NAME: ${match.name}');
                              debugPrint(
                                '[COACH SELECTED]\nid=${match.id}\nname=${match.name}',
                              );
                              setState(() {
                                _selectedCoach = match;
                                _selectedCoachId = match.id;
                              });
                            },
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              BlocSelector<BookingCubit, BookingState, bool>(
                selector: (state) =>
                    state.status == BookingActionStatus.loading,
                builder: (context, isLoading) {
                  return FilledButton.icon(
                    onPressed: isLoading || _selectedCoach == null
                        ? null
                        : () {
                            final coach = _selectedCoach;
                            if (coach == null) {
                              _reportInvalidCoachSelection(
                                selectedCoachId: _selectedCoachId,
                                coaches: widget.parentContext
                                    .read<CoachesCubit>()
                                    .state
                                    .coaches,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Invalid coach selection. Please choose again.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            debugPrint(
                              '[BOOK FLOW]\nCourt details book clicked',
                            );
                            debugPrint(
                              '[NAVIGATION]\nOpening booking confirmation page',
                            );
                            if (mounted) {
                              Navigator.of(context).pop();
                              context.push(
                                '/booking/confirm',
                                extra: BookingFlowArgs(
                                  court: widget.args.court,
                                  slot: widget.slot,
                                  coachId: coach.id,
                                  coachName: coach.name,
                                ),
                              );
                            }
                          },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isLoading
                          ? const SizedBox.square(
                              key: ValueKey('loading'),
                              dimension: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.verified_rounded,
                              key: ValueKey('icon'),
                            ),
                    ),
                    label: Text(
                      isLoading ? 'Confirming...' : 'Confirm booking',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
