import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key, required this.args});

  final BookingFlowArgs? args;

  @override
  Widget build(BuildContext context) {
    final flow = args;
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
        final user = context.read<AuthCubit>().state.user;
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
                      _SummaryRow(label: 'Coach', value: flow.court.coach.name),
                      _SummaryRow(
                        label: 'Member',
                        value: user?.name ?? 'Guest',
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: '\$${flow.court.hourlyRate.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Confirm reservation',
                icon: Icons.verified_rounded,
                isLoading: state.status == BookingActionStatus.loading,
                onPressed: () => context.read<BookingCubit>().reserve(
                  userId: user?.id ?? 'guest',
                  userName: user?.name ?? 'Guest Member',
                  court: flow.court,
                  slot: flow.slot,
                ),
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
