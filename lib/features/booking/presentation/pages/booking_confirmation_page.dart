import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/presentation/cubit/coaches_cubit.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';

class BookingConfirmationPage extends StatefulWidget {
  const BookingConfirmationPage({super.key, required this.args});

  final BookingFlowArgs? args;

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  String? _selectedCoachId;

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
    final cubit = context.read<CoachesCubit>();
    cubit.watchCoaches();
  }

  @override
  Widget build(BuildContext context) {
    final flow = widget.args;
    final authUser = context.read<AuthCubit>().state.user;
    if (flow == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No booking selected',
          message: 'Return to the dashboard and choose a slot.',
        ),
      );
    }

    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (!context.mounted) return;
        if (state.status == BookingActionStatus.success) {
          context.go('/booking/success');
        }
        if (state.status == BookingActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Booking failed')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Confirm booking')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reservation summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(label: 'Court', value: flow.court.name),
                      _SummaryRow(
                        label: 'Date',
                        value: flow.slot.startsAt.readableDate,
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value:
                            '\$${flow.court.pricePerHour.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CoachesCubit, CoachesState>(
                builder: (context, state) {
                  final selectedCoach = _findCoachById(
                    state.coaches,
                    _selectedCoachId,
                  );
                  if (_selectedCoachId != null && selectedCoach == null) {
                    _reportInvalidCoachSelection(
                      selectedCoachId: _selectedCoachId,
                      coaches: state.coaches,
                    );
                  }
                  return DropdownButtonFormField<String>(
                    key: ValueKey(
                      'coach-dropdown-${_selectedCoachId ?? 'none'}-${state.coaches.length}',
                    ),
                    initialValue: selectedCoach?.id,
                    decoration: const InputDecoration(
                      labelText: 'Coach',
                      prefixIcon: Icon(Icons.sports_rounded),
                    ),
                    items: [
                      for (final coach in state.coaches)
                        DropdownMenuItem(
                          value: coach.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage:
                                    coach.imageUrl?.isNotEmpty == true
                                    ? CachedNetworkImageProvider(
                                        coach.imageUrl!,
                                      )
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
                            final match = _findCoachById(state.coaches, value);
                            if (match == null) {
                              _reportInvalidCoachSelection(
                                selectedCoachId: value,
                                coaches: state.coaches,
                              );
                              setState(() => _selectedCoachId = null);
                              return;
                            }
                            debugPrint('SELECTED COACH ID: ${match.id}');
                            debugPrint('SELECTED COACH NAME: ${match.name}');
                            debugPrint(
                              '[COACH SELECTED]\nid=${match.id}\nname=${match.name}',
                            );
                            setState(() {
                              _selectedCoachId = match.id;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Confirm reservation',
                icon: Icons.verified_rounded,
                isLoading: state.status == BookingActionStatus.loading,
                onPressed: _selectedCoachId == null
                    ? null
                    : () {
                        final coachesState = context.read<CoachesCubit>().state;
                        final selectedCoach = _findCoachById(
                          coachesState.coaches,
                          _selectedCoachId,
                        );
                        if (selectedCoach == null) {
                          _reportInvalidCoachSelection(
                            selectedCoachId: _selectedCoachId,
                            coaches: coachesState.coaches,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invalid coach selection. Please choose again.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (selectedCoach.id != _selectedCoachId) {
                          _reportInvalidCoachSelection(
                            selectedCoachId: _selectedCoachId,
                            coaches: coachesState.coaches,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Coach selection mismatch. Please choose again.',
                              ),
                            ),
                          );
                          return;
                        }
                        debugPrint('BOOKING COACH ID: ${selectedCoach.id}');
                        debugPrint('BOOKING COACH NAME: ${selectedCoach.name}');
                        debugPrint(
                          '[COACH SELECTED]\nid=${selectedCoach.id}\nname=${selectedCoach.name}',
                        );
                        debugPrint(
                          '[BOOKING CREATED]\ncoachId=${selectedCoach.id}\ncoachName=${selectedCoach.name}',
                        );
                        context.read<BookingCubit>().reserve(
                          coachId: selectedCoach.id,
                          coachName: selectedCoach.name,
                          court: flow.court,
                          slot: flow.slot,
                          bookedByUserId: authUser?.id,
                        );
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
