import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';
import 'package:honset_app/shared/widgets/status_badge.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key, required this.args});

  final BookingFlowArgs? args;

  @override
  Widget build(BuildContext context) {
    final flow = args;
    if (flow == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'Select a slot first',
          message: 'Choose an available slot from the court dashboard.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            flow.court.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(flow.court.description),
          const SizedBox(height: 20),
          _DetailTile(
            icon: Icons.calendar_today_rounded,
            title: 'Date',
            value: flow.slot.startsAt.readableDate,
          ),
          _DetailTile(
            icon: Icons.schedule_rounded,
            title: 'Time',
            value:
                '${flow.slot.startsAt.timeLabel} - ${flow.slot.endsAt.timeLabel}',
          ),
          _DetailTile(
            icon: Icons.sports_rounded,
            title: 'Coach',
            value: flow.court.coach.name,
          ),
          _DetailTile(
            icon: Icons.payments_rounded,
            title: 'Court fee',
            value: '\$${flow.court.hourlyRate.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge.slot(flow.slot.status),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Continue to confirmation',
            icon: Icons.arrow_forward_rounded,
            onPressed: flow.slot.canBook
                ? () => context.push('/booking/confirm', extra: flow)
                : null,
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
