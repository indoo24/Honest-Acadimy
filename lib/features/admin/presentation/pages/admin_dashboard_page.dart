import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/status_badge.dart';

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
        title: const Text('Admin dashboard'),
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
          if (state.status == AdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => context.read<AdminCubit>().loadDailyOverview(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Today overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _AnalyticsGrid(state: state),
                const SizedBox(height: 24),
                Text(
                  'Calendar management',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                _CalendarManagementCard(),
                const SizedBox(height: 24),
                Text(
                  'Daily bookings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                if (state.bookings.isEmpty)
                  const EmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'No bookings today',
                    message:
                        'New reservations and admin-added bookings appear here.',
                  )
                else
                  ...state.bookings.map(
                    (booking) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.squashGreen.withValues(
                            alpha: .14,
                          ),
                          child: const Icon(Icons.sports_tennis_rounded),
                        ),
                        title: Text(
                          '${booking.courtName} • ${booking.userName}',
                        ),
                        subtitle: Text(
                          '${booking.startsAt.timeLabel} - ${booking.endsAt.timeLabel}',
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusBadge.booking(booking.status),
                            IconButton(
                              tooltip: 'Cancel booking',
                              onPressed: () => context
                                  .read<AdminCubit>()
                                  .cancelBooking(booking.id),
                              icon: const Icon(Icons.cancel_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddBookingSheet(BuildContext context) {
    final courts = context.read<AdminCubit>().state.courts;
    var selectedCourtId = courts.isNotEmpty ? courts.first.id : '';
    var selectedDate = DateTime.now();
    var selectedHour = 18;
    final memberController = TextEditingController(text: 'Walk-in Member');

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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: memberController,
                      decoration: const InputDecoration(
                        labelText: 'Member name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCourtId.isEmpty
                          ? null
                          : selectedCourtId,
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 45),
                                ),
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
                      onPressed: selectedCourtId.isEmpty
                          ? null
                          : () {
                              context.read<AdminCubit>().addManualBooking(
                                courtId: selectedCourtId,
                                memberName: memberController.text,
                                date: selectedDate,
                                hour: selectedHour,
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
    ).whenComplete(memberController.dispose);
  }
}

class _AnalyticsGrid extends StatelessWidget {
  const _AnalyticsGrid({required this.state});

  final AdminState state;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _Metric(
        'Bookings',
        state.bookings.length.toString(),
        Icons.event_note_rounded,
      ),
      _Metric(
        'Confirmed',
        state.confirmedCount.toString(),
        Icons.verified_rounded,
      ),
      _Metric(
        'Revenue',
        '\$${state.revenue.toStringAsFixed(0)}',
        Icons.payments_rounded,
      ),
      _Metric(
        'Utilization',
        '${(state.bookings.length * 7).clamp(0, 100)}%',
        Icons.analytics_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      card.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card.value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(card.label),
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

class _CalendarManagementCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.rallyOrange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Schedules are stored in Firestore schedules documents by court and slot start time.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Manage'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
