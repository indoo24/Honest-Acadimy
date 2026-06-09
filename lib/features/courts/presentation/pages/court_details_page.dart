import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/domain/usecases/generate_slots.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/presentation/cubit/coaches_cubit.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_cubit.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';

class CourtDetailsPage extends StatefulWidget {
  const CourtDetailsPage({super.key, required this.args});

  final CourtDetailsArgs? args;

  @override
  State<CourtDetailsPage> createState() => _CourtDetailsPageState();
}

class _CourtDetailsPageState extends State<CourtDetailsPage> {
  BookingSlot? _selectedSlot;
  List<BookingSlot> _slots = const [];
  bool _isLoadingSlots = false;
  String? _slotLoadError;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.args?.initialSlot;
    _slots = widget.args?.slots ?? const [];
    _loadCourtDetailsSlots();
  }

  DateTime _detailsDate(CourtDetailsArgs args) {
    final source =
        args.selectedDate ??
        args.initialSlot?.startsAt ??
        (args.slots.isNotEmpty ? args.slots.first.startsAt : DateTime.now());
    return DateTime(source.year, source.month, source.day);
  }

  Future<void> _loadCourtDetailsSlots() async {
    final args = widget.args;
    if (args == null) return;
    final date = _detailsDate(args);
    setState(() {
      _isLoadingSlots = true;
      _slotLoadError = null;
    });
    try {
      final availability = await getIt<CourtAvailabilityRepository>()
          .getAvailabilityByCourtId(args.court.id);
      final bookings = await getIt<FirestoreBookingDataSource>()
          .getActiveBookingsForCourt(courtId: args.court.id, date: date);
      debugPrint(
        '[COURT DETAILS BOOKINGS]\n'
        'courtId: ${args.court.id}\n'
        'date: $date\n'
        'bookings count: ${bookings.length}',
      );
      final slots = availability == null
          ? <BookingSlot>[]
          : getIt<SlotGenerator>().generate(
              date: date,
              availability: availability,
              bookings: bookings,
            );
      for (final slot in slots) {
        debugPrint(
          '[SLOT MERGE]\n'
          'time: ${slot.startsAt.timeLabel}\n'
          'status: ${slot.status.name}',
        );
      }
      if (!mounted) return;
      setState(() {
        _slots = slots;
        _selectedSlot = _matchingSlot(slots, _selectedSlot);
        _isLoadingSlots = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingSlots = false;
        _slotLoadError = error.toString();
      });
    }
  }

  BookingSlot? _matchingSlot(
    List<BookingSlot> slots,
    BookingSlot? selectedSlot,
  ) {
    if (selectedSlot == null) return null;
    for (final slot in slots) {
      if (slot.id == selectedSlot.id) return slot;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.sports_tennis_rounded,
          title: 'Court not selected',
          message: 'Return to the booking dashboard and choose a court.',
        ),
      );
    }

    final court = args.court;
    return Scaffold(
      appBar: AppBar(title: Text(court.name)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: MediaQuery.sizeOf(context).width < 600 ? 1.45 : 2.8,
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
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
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
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: .82,
                                        ),
                                      ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${court.pricePerHour.toStringAsFixed(0)} / hour',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: .9),
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
            ),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Available time slots',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                if (_isLoadingSlots) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(),
                ],
                if (_slotLoadError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _slotLoadError!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.dangerRed),
                  ),
                ],
                const SizedBox(height: 12),
                _ResponsiveSlotWrap(
                  slots: _slots,
                  selectedSlot: _selectedSlot,
                  onSelected: (slot) => setState(() => _selectedSlot = slot),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _selectedSlot?.canBook == true
                      ? () => _showBookingSheet(context, args)
                      : null,
                  icon: const Icon(Icons.event_available_rounded),
                  label: Text(
                    _selectedSlot == null
                        ? 'Select an available slot'
                        : 'Book ${_selectedSlot!.startsAt.timeLabel}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBookingSheet(
    BuildContext context,
    CourtDetailsArgs args,
  ) async {
    final slot = _selectedSlot;
    if (slot == null || !slot.canBook) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return _BookingSheet(parentContext: context, args: args, slot: slot);
      },
    );
    if (mounted) await _loadCourtDetailsSlots();
  }
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.parentContext,
    required this.args,
    required this.slot,
  });

  final BuildContext parentContext;
  final CourtDetailsArgs args;
  final BookingSlot slot;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String? _selectedCoachId;
  CoachProfile? _selectedCoach;
  String? _bookedByUserId;

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
    final user = widget.parentContext.read<AuthCubit>().state.user;
    _bookedByUserId = user?.id;
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
          ).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.args.court.name} • ${widget.slot.startsAt.timeLabel}',
              ),
              const SizedBox(height: 6),
              Text(
                '\$${widget.args.court.pricePerHour.toStringAsFixed(0)} / hour',
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
                                  style: Theme.of(context).textTheme.labelSmall
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
                        : () async {
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
                            if (coach.id != _selectedCoachId) {
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
                                      'Coach selection mismatch. Please choose again.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            debugPrint('SELECTED COACH ID: ${coach.id}');
                            debugPrint('SELECTED COACH NAME: ${coach.name}');
                            debugPrint('BOOKING COACH ID: ${coach.id}');
                            debugPrint('BOOKING COACH NAME: ${coach.name}');
                            debugPrint(
                              '[COACH SELECTED]\nid=${coach.id}\nname=${coach.name}',
                            );
                            debugPrint(
                              '[BOOKING CREATED]\ncoachId=${coach.id}\ncoachName=${coach.name}',
                            );
                            await context.read<BookingCubit>().reserve(
                              coachId: coach.id,
                              coachName: coach.name,
                              court: widget.args.court,
                              slot: widget.slot,
                              bookedByUserId: _bookedByUserId,
                            );
                            if (!mounted) return;
                          },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isLoading
                          ? const SizedBox.square(
                              key: ValueKey('loading'),
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
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

class _ResponsiveSlotWrap extends StatelessWidget {
  const _ResponsiveSlotWrap({
    required this.slots,
    required this.selectedSlot,
    required this.onSelected,
  });

  final List<BookingSlot> slots;
  final BookingSlot? selectedSlot;
  final ValueChanged<BookingSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const EmptyState(
        icon: Icons.schedule_rounded,
        title: 'No availability configured',
        message: 'The club has not set availability rules for this court yet.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth < 420
            ? (constraints.maxWidth - 10) / 2
            : 118.0;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final slot in slots)
              SizedBox(
                width: itemWidth.clamp(120, 140),
                child: _SlotButton(
                  slot: slot,
                  selected: selectedSlot?.id == slot.id,
                  onTap: slot.canBook ? () => onSelected(slot) : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final BookingSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (slot.status) {
      SlotStatus.available => AppColors.squashGreen,
      SlotStatus.reserved => AppColors.dangerRed,
      SlotStatus.pending => AppColors.rallyOrange,
      SlotStatus.past => Colors.grey,
    };
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? color.withValues(alpha: .22)
            : color.withValues(alpha: .08),
        side: BorderSide(
          color: selected ? color : color.withValues(alpha: .45),
          width: selected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slot.startsAt.timeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            selected
                ? 'Selected'
                : slot.status == SlotStatus.reserved
                ? (slot.coachName ?? 'Reserved')
                : slot.status.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
