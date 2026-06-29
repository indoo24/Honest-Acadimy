import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/l10n/app_localizations.dart';
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

/// Sentinel value used when the user opts out of coach selection.
const _kNoCoachId = 'no_coach';

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  String? _selectedCoachId;
  String _selectedPaymentMethod = 'cash';
  final TextEditingController _clientNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isNoCoach => _selectedCoachId == _kNoCoachId;

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
    _selectedCoachId = widget.args?.coachId;
    final cubit = context.read<CoachesCubit>();
    cubit.watchCoaches();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = widget.args;
    final authUser = context.read<AuthCubit>().state.user;
    if (flow == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.event_busy_rounded,
          title: AppLocalizations.of(context)!.noBookingSelected,
          message: AppLocalizations.of(context)!.returnToDashboardSlot,
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
            SnackBar(content: Text(state.message ?? AppLocalizations.of(context)!.bookingFailed)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.confirmBookingTitle)),
          body: Form(
            key: _formKey,
            child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.reservationSummary,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(label: AppLocalizations.of(context)!.court, value: flow.court.name),
                      _SummaryRow(
                        label: AppLocalizations.of(context)!.date,
                        value: flow.slot.startsAt.readableDate,
                      ),
                      _SummaryRow(
                        label: AppLocalizations.of(context)!.total,
                        value:
                            '${flow.court.pricePerHour.toStringAsFixed(0)}جنيه ',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CoachesCubit, CoachesState>(
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context)!;
                  final selectedCoach = _findCoachById(
                    state.coaches,
                    _selectedCoachId,
                  );
                  // Skip validation for the "No Coach" sentinel.
                  if (_selectedCoachId != null &&
                      !_isNoCoach &&
                      selectedCoach == null) {
                    _reportInvalidCoachSelection(
                      selectedCoachId: _selectedCoachId,
                      coaches: state.coaches,
                    );
                  }
                  return SizedBox(
                      width: 180, // 👈 حددنا له العرض هنا بره عشان نلجم الـ 26 بكسل الزيادة
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(
                          'coach-dropdown-${_selectedCoachId ?? 'none'}-${state.coaches.length}',
                        ),
                        initialValue: _isNoCoach
                            ? _kNoCoachId
                            : selectedCoach?.id,

                        // 👈 السطر ده أساسي عشان يخلي النص والأيقونة يلتزموا بالـ 180 بكسل
                        isExpanded: true,

                        decoration: InputDecoration(
                          labelText: l10n.coach,
                          prefixIcon: const Icon(Icons.sports_rounded),
                        ),
                    items: [
                      // ── "No Coach" option ──
                      DropdownMenuItem(
                        value: _kNoCoachId,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.person_off_rounded, size: 14),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                l10n.noCoach,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Real coaches ──
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
                            // Handle "No Coach" selection.
                            if (value == _kNoCoachId) {
                              debugPrint('[COACH SELECTED] No Coach');
                              setState(() => _selectedCoachId = _kNoCoachId);
                              return;
                            }
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
                  ));
                },
              ),
              // ── Client Name field (visible only when "No Coach" is selected) ──
              if (_isNoCoach) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clientNameController,
                  style: const TextStyle(color: Color(0xFF0A84FF)),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.clientName,
                    labelStyle: const TextStyle(color: Color(0xFF0A84FF)),
                    hintText: AppLocalizations.of(context)!.clientName,
                    hintStyle: TextStyle(color: const Color(0xFF0A84FF).withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF0A84FF)),
                    filled: true,
                    fillColor: const Color(0xFF161B26),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.clientNameRequired;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.paymentMethod,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context)!.cash),
                value: 'cash',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    debugPrint('[PAYMENT SELECTED] method=$value');
                    setState(() => _selectedPaymentMethod = value);
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context)!.instaPay),
                value: 'instapay',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    debugPrint('[PAYMENT SELECTED] method=$value');
                    setState(() => _selectedPaymentMethod = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: AppLocalizations.of(context)!.confirmReservation,
                icon: Icons.verified_rounded,
                isLoading: state.status == BookingActionStatus.loading,
                onPressed: _selectedCoachId == null
                    ? null
                    : () {
                        // Validate form (includes client name when No Coach).
                        if (!_formKey.currentState!.validate()) return;

                        final l10n = AppLocalizations.of(context)!;

                        // Resolve coachId / coachName.
                        final String resolvedCoachId;
                        final String resolvedCoachName;

                        if (_isNoCoach) {
                          resolvedCoachId = _kNoCoachId;
                          resolvedCoachName = _clientNameController.text.trim();
                          debugPrint('[BOOKING CREATED] No Coach selected – client name: $resolvedCoachName');
                        } else {
                          final coachesState =
                              context.read<CoachesCubit>().state;
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
                              SnackBar(
                                content: Text(l10n.invalidCoachSelection),
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
                              SnackBar(
                                content: Text(l10n.coachSelectionMismatch),
                              ),
                            );
                            return;
                          }
                          resolvedCoachId = selectedCoach.id;
                          resolvedCoachName = selectedCoach.name;
                          debugPrint(
                            'BOOKING COACH ID: ${selectedCoach.id}',
                          );
                          debugPrint(
                            'BOOKING COACH NAME: ${selectedCoach.name}',
                          );
                          debugPrint(
                            '[COACH SELECTED]\nid=${selectedCoach.id}\nname=${selectedCoach.name}',
                          );
                          debugPrint(
                            '[BOOKING CREATED]\ncoachId=${selectedCoach.id}\ncoachName=${selectedCoach.name}',
                          );
                        }

                        if (_selectedPaymentMethod == 'instapay') {
                          context.push(
                            '/booking/payment',
                            extra: BookingPaymentArgs(
                              court: flow.court,
                              slot: flow.slot,
                              coachId: resolvedCoachId,
                              coachName: resolvedCoachName,
                            ),
                          );
                          return;
                        }
                        debugPrint('[RESERVE CALLED]\nmethod=cash');
                        context.read<BookingCubit>().reserve(
                          coachId: resolvedCoachId,
                          coachName: resolvedCoachName,
                          court: flow.court,
                          slot: flow.slot,
                          bookedByUserId: authUser?.id,
                          paymentMethod: 'cash',
                        );
                      },
              ),
            ],
          ),
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
