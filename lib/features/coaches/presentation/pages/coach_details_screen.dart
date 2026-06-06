import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_availability_slot.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';

class CoachDetailsScreen extends StatelessWidget {
  const CoachDetailsScreen({super.key, required this.args});

  final CoachDetailsArgs? args;

  @override
  Widget build(BuildContext context) {
    final details = args;
    if (details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.people_alt_rounded,
          title: 'Coach not found',
          message: 'Select a coach from the academy list.',
        ),
      );
    }

    return StreamBuilder<CoachProfile?>(
      stream: getIt<CoachRepository>().watchCoach(details.coachId),
      builder: (context, snapshot) {
        final coach = snapshot.data ?? details.coach;
        if (coach == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final available = coach.availableSlots
            .where((slot) => slot.status == CoachSlotStatus.available)
            .toList();
        final reserved = coach.availableSlots
            .where((slot) => slot.status == CoachSlotStatus.reserved)
            .toList();
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(coach.name),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'coach-image-${coach.id}',
                        child: CachedNetworkImage(
                          imageUrl: coach.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.clubNavy.withValues(alpha: .08),
                            child: const Center(
                              child: Icon(Icons.person_rounded, size: 48),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.clubNavy.withValues(alpha: .08),
                            child: const Center(
                              child: Icon(Icons.person_rounded, size: 48),
                            ),
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: .05),
                              Colors.black.withValues(alpha: .72),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _HeaderSummary(coach: coach),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'About coach',
                        child: Text(
                          coach.bio,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Available training times',
                        child: _AvailabilityGrid(slots: available),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Upcoming reservations',
                        child: _AvailabilityGrid(
                          slots: reserved,
                          emptyMessage: 'No upcoming reservations yet.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Assigned courts',
                        child: _CourtsWrap(courts: coach.assignedCourts),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Training specialty',
                        child: Text(
                          coach.specialty,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Weekly availability',
                        child: _WeeklyAvailability(slots: coach.availableSlots),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.coach});

  final CoachProfile coach;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage: coach.imageUrl?.isNotEmpty == true
                  ? CachedNetworkImageProvider(coach.imageUrl!)
                  : null,
              child: coach.imageUrl?.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person_rounded, size: 34),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.specialty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.squashGreen,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${coach.yearsExperience} years experience',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.courtGold),
                      const SizedBox(width: 6),
                      Text(
                        coach.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _AvailabilityGrid extends StatelessWidget {
  const _AvailabilityGrid({required this.slots, this.emptyMessage});

  final List<CoachAvailabilitySlot> slots;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return EmptyState(
        icon: Icons.schedule_rounded,
        title: 'No slots available',
        message: emptyMessage ?? 'The coach has no slots right now.',
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final slot in slots)
          _AvailabilityChip(
            label: '${slot.startsAt.timeLabel} - ${slot.endsAt.timeLabel}',
            status: slot.status,
          ),
      ],
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.label, required this.status});

  final String label;
  final CoachSlotStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CoachSlotStatus.available => AppColors.squashGreen,
      CoachSlotStatus.reserved => AppColors.dangerRed,
      CoachSlotStatus.unavailable => Colors.grey,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CourtsWrap extends StatelessWidget {
  const _CourtsWrap({required this.courts});

  final List<String> courts;

  @override
  Widget build(BuildContext context) {
    if (courts.isEmpty) {
      return const Text('No courts assigned yet.');
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final court in courts)
          Chip(
            label: Text(court.replaceAll('-', ' ').toUpperCase()),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
      ],
    );
  }
}

class _WeeklyAvailability extends StatelessWidget {
  const _WeeklyAvailability({required this.slots});

  final List<CoachAvailabilitySlot> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Text('Weekly availability will appear once slots are added.');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in _groupByDay(slots).entries)
          _AvailabilityChip(
            label: '${entry.key}: ${entry.value} slots',
            status: entry.value == 0
                ? CoachSlotStatus.unavailable
                : CoachSlotStatus.available,
          ),
      ],
    );
  }

  Map<String, int> _groupByDay(List<CoachAvailabilitySlot> slots) {
    final dayCounts = <String, int>{};
    for (final slot in slots) {
      final day = slot.startsAt.shortDay;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    return dayCounts;
  }
}
