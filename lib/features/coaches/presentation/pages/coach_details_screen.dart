import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/booking/data/models/booking_model.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
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
        debugPrint(
          '[COACH PAGE]\ncoachId=${coach.id}\nweeklyAvailability=${_weeklyAvailabilityLog(coach.weeklyAvailability)}',
        );
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
                  delegate: SliverChildListDelegate([
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
                      title: 'Training specialty',
                      child: Text(
                        coach.specialty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Weekly availability',
                      child: _WeeklyAvailabilityCard(
                        weeklyAvailability: coach.weeklyAvailability,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Coach reservations',
                      child: StreamBuilder<List<Booking>>(
                        stream: _coachBookingsStream(coach.id),
                        builder: (context, bookingSnapshot) {
                          if (bookingSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final bookings = bookingSnapshot.data ?? const [];
                          if (bookings.isEmpty) {
                            return const EmptyState(
                              icon: Icons.event_available_rounded,
                              title: 'No reservations yet',
                              message: '',
                            );
                          }
                          return _CoachReservationsCard(bookings: bookings);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<List<Booking>> _coachBookingsStream(String coachId) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('coachId', isEqualTo: coachId)
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final bookings = snapshot.docs
              .map(BookingModel.fromFirestore)
              .where((booking) => !booking.startsAt.isBefore(now))
              .toList();
          debugPrint(
            '[COACH BOOKINGS]\ncount=${bookings.length}\ncoachId=$coachId',
          );
          return bookings;
        });
  }

  static String _weeklyAvailabilityLog(
    Map<String, WeeklyAvailabilityRange> weeklyAvailability,
  ) {
    return weeklyAvailability.map((day, range) {
      return MapEntry(day, {
        'startHour': range.startHour,
        'endHour': range.endHour,
      });
    }).toString();
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
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.courtGold,
                      ),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _WeeklyAvailabilityCard extends StatelessWidget {
  const _WeeklyAvailabilityCard({required this.weeklyAvailability});

  final Map<String, WeeklyAvailabilityRange> weeklyAvailability;

  static const List<String> _orderedDays = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  @override
  Widget build(BuildContext context) {
    if (weeklyAvailability.isEmpty) {
      return const EmptyState(
        icon: Icons.schedule_rounded,
        title: 'No weekly availability set',
        message: '',
      );
    }

    final entries = weeklyAvailability.entries.toList()
      ..sort((a, b) {
        final aIndex = _orderedDays.indexOf(a.key.toLowerCase());
        final bIndex = _orderedDays.indexOf(b.key.toLowerCase());
        if (aIndex == -1 && bIndex == -1) return a.key.compareTo(b.key);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              _WeeklyAvailabilityRow(
                day: entries[i].key,
                range: entries[i].value,
              ),
              if (i != entries.length - 1)
                Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: .2),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeeklyAvailabilityRow extends StatelessWidget {
  const _WeeklyAvailabilityRow({required this.day, required this.range});

  final String day;
  final WeeklyAvailabilityRange range;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _capitalize(day),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.squashGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_formatHour(range.startHour)} - ${_formatHour(range.endHour)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.squashGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    final clamped = hour.clamp(0, 23);
    final date = DateTime(2000, 1, 1, clamped);
    return date.timeLabel;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class _CoachReservationsCard extends StatelessWidget {
  const _CoachReservationsCard({required this.bookings});

  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (var i = 0; i < bookings.length; i++) ...[
              _ReservationRow(booking: bookings[i]),
              if (i != bookings.length - 1)
                Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: .2),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReservationRow extends StatelessWidget {
  const _ReservationRow({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.startsAt.readableDate,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.startsAt.shortDay} • ${booking.startsAt.timeLabel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  booking.courtName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(booking.status).withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _statusLabel(booking.status),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _statusColor(booking.status),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending_payment => 'Pending payment',
      BookingStatus.pending_payment_review => 'Pending review',
      BookingStatus.confirmed => 'Confirmed',
      BookingStatus.rejected => 'Rejected',
      BookingStatus.cancelled => 'Cancelled',
    };
  }

  Color _statusColor(BookingStatus status) {
    return switch (status) {
      BookingStatus.confirmed => AppColors.squashGreen,
      BookingStatus.pending_payment ||
      BookingStatus.pending_payment_review => AppColors.rallyOrange,
      BookingStatus.rejected || BookingStatus.cancelled => AppColors.dangerRed,
    };
  }
}
