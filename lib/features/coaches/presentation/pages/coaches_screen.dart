import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/presentation/cubit/coaches_cubit.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/skeleton_loader.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CoachesCubit>();
    cubit.watchCoaches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaches'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<CoachesCubit>().watchCoaches(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CoachesCubit, CoachesState>(
        builder: (context, state) {
          if (state.status == CoachesStatus.loading) {
            return const _CoachesSkeleton();
          }
          if (state.status == CoachesStatus.failure) {
            return EmptyState(
              icon: Icons.sports_tennis_rounded,
              title: 'Coaches unavailable',
              message: state.message ?? 'We could not load the academy coaches.',
            );
          }
          if (state.coaches.isEmpty) {
            return const EmptyState(
              icon: Icons.people_alt_rounded,
              title: 'No coaches found',
              message: 'The academy has no active coaches right now.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isGrid = constraints.maxWidth >= 760;
              final padding = EdgeInsets.symmetric(
                horizontal: isGrid ? 24 : 18,
                vertical: 16,
              );
              if (!isGrid) {
                return ListView.separated(
                  padding: padding,
                  itemCount: state.coaches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _CoachCard(
                    coach: state.coaches[index],
                    onViewProfile: () => _openCoach(context, state.coaches[index]),
                  ),
                );
              }
              final columns = constraints.maxWidth >= 1180 ? 3 : 2;
              final itemWidth = (constraints.maxWidth - padding.horizontal -
                      (columns - 1) * 16) /
                  columns;
              return GridView.builder(
                padding: padding,
                itemCount: state.coaches.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: itemWidth.clamp(320, 420).toDouble(),
                ),
                itemBuilder: (context, index) => _CoachCard(
                  coach: state.coaches[index],
                  onViewProfile: () => _openCoach(context, state.coaches[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openCoach(BuildContext context, CoachProfile coach) {
    context.push(
      '/coaches/details',
      extra: CoachDetailsArgs(coachId: coach.id, coach: coach),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.onViewProfile});

  final CoachProfile coach;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Hero(
                    tag: 'coach-image-${coach.id}',
                    child: CachedNetworkImage(
                      imageUrl: coach.imageUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.clubNavy.withValues(alpha: .08),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 42),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.clubNavy.withValues(alpha: .08),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 42),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _AvailabilityPill(isActive: coach.isActive),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coach.specialty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.squashGreen,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    coach.description ?? coach.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: '${coach.yearsExperience} yrs',
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.star_rounded,
                        label: coach.rating.toStringAsFixed(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onViewProfile,
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('View profile'),
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

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.squashGreen : Colors.grey;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle_rounded : Icons.schedule_rounded,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? 'Available' : 'Unavailable',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _CoachesSkeleton extends StatelessWidget {
  const _CoachesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SkeletonBox(height: 220),
        SizedBox(height: 16),
        SkeletonBox(height: 220),
        SizedBox(height: 16),
        SkeletonBox(height: 220),
      ],
    );
  }
}
