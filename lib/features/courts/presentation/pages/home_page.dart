import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_cubit.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_state.dart';
import 'package:honset_app/shared/widgets/app_logo.dart';
import 'package:honset_app/shared/widgets/error_state.dart';
import 'package:honset_app/shared/widgets/skeleton_loader.dart';
import 'package:honset_app/shared/widgets/status_badge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CourtsCubit>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourtsCubit, CourtsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const AppLogo(size: 40),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => context.read<CourtsCubit>().loadDashboard(),
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: switch (state.status) {
            CourtsStatus.failure => ErrorStateView(
                message: state.message ?? 'Could not load courts.',
                onRetry: () => context.read<CourtsCubit>().loadDashboard(),
              ),
            CourtsStatus.loading ||
            CourtsStatus.initial => const _DashboardSkeleton(),
            CourtsStatus.loaded => _DashboardContent(
                key: ValueKey('content-${state.courts.length}'),
                state: state,
              ),
          },
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({super.key, required this.state});

  final CourtsState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Court reservations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Live availability across all squash courts.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                _DateStrip(selectedDate: state.selectedDate),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              if (width < 720) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final court = state.courts[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == state.courts.length - 1 ? 0 : 18,
                      ),
                      child: _CourtCard(
                        court: court,
                        slots: state.slotsByCourt[court.id] ?? const [],
                      ),
                    );
                  }, childCount: state.courts.length),
                );
              }
              const columns = 2;
              final itemWidth = (width - 18) / columns;
              final itemHeight = (itemWidth / (16 / 9)) + 244;
              return SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final court = state.courts[index];
                  return _CourtCard(
                    court: court,
                    slots: state.slotsByCourt[court.id] ?? const [],
                  );
                }, childCount: state.courts.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  mainAxisExtent: itemHeight.clamp(500, 620).toDouble(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = day.isSameDate(selectedDate);
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.read<CourtsCubit>().loadDashboard(date: day),
            child: Container(
              width: 68,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.clubNavy
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? AppColors.squashGreen
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.shortDay,
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? Colors.white70 : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.dayNumber,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: selected ? Colors.white : null,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({required this.court, required this.slots});

  final Court court;
  final List<BookingSlot> slots;

  @override
  Widget build(BuildContext context) {
    final nextAvailable = slots.where((slot) => slot.canBook).firstOrNull;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          '/court/details',
          extra: CourtDetailsArgs(court: court, slots: slots),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.squashGreen.withValues(alpha: 0.3),
                          AppColors.clubNavy.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sports_tennis_rounded,
                        size: 64,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: StatusBadge.slot(
                      nextAvailable == null
                          ? SlotStatus.reserved
                          : SlotStatus.available,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .42),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          '\$${court.pricePerHour.toStringAsFixed(0)} / hour',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  if (court.description != null && court.description!.isNotEmpty)
                    Text(
                      court.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 14),
                  _SlotTimeline(
                    court: court,
                    slots: slots,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push(
                        '/court/details',
                        extra: CourtDetailsArgs(
                          court: court,
                          slots: slots,
                          initialSlot: nextAvailable,
                        ),
                      ),
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text(
                        nextAvailable == null
                            ? 'View details'
                            : 'Book ${nextAvailable.startsAt.timeLabel}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

class _SlotTimeline extends StatelessWidget {
  const _SlotTimeline({
    required this.court,
    required this.slots,
  });

  final Court court;
  final List<BookingSlot> slots;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final slot = slots[index];
          final coachLabel = slot.coachName == null
              ? ''
              : ' • ${slot.coachName}';
          return Tooltip(
            message: '${slot.startsAt.timeLabel} ${slot.status.name}$coachLabel',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: slot.canBook
                  ? () => context.push(
                      '/court/details',
                      extra: CourtDetailsArgs(
                        court: court,
                        slots: slots,
                        initialSlot: slot,
                      ),
                    )
                  : null,
              child: Container(
                width: 72,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _slotColor(slot.status).withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _slotColor(slot.status).withValues(alpha: .5),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slot.startsAt.timeLabel.replaceAll(' ', ''),
                        maxLines: 1,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: _slotColor(slot.status),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _slotIcon(slot.status),
                        size: 16,
                        color: _slotColor(slot.status),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _slotIcon(SlotStatus status) {
    return switch (status) {
      SlotStatus.available => Icons.check_circle_rounded,
      SlotStatus.reserved => Icons.block_rounded,
      SlotStatus.pending => Icons.schedule_rounded,
      SlotStatus.past => Icons.history_rounded,
    };
  }

  Color _slotColor(SlotStatus status) {
    return switch (status) {
      SlotStatus.available => AppColors.squashGreen,
      SlotStatus.reserved => AppColors.dangerRed,
      SlotStatus.pending => AppColors.rallyOrange,
      SlotStatus.past => Colors.grey,
    };
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonBox(height: 30, width: 220),
        SizedBox(height: 14),
        SkeletonBox(height: 86),
        SizedBox(height: 18),
        SkeletonBox(height: 420),
        SizedBox(height: 18),
        SkeletonBox(height: 420),
      ],
    );
  }
}