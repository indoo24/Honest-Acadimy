import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/status_badge.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthCubit>().state.user;
      context.read<BookingCubit>().loadHistory(user?.id ?? 'guest');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking history')),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state.status == BookingActionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.history.isEmpty) {
            return const EmptyState(
              icon: Icons.confirmation_number_outlined,
              title: 'No bookings yet',
              message:
                  'Your confirmed and pending reservations will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = state.history[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.sports_tennis_rounded),
                  title: Text(booking.courtName),
                  subtitle: Text(
                    '${booking.startsAt.readableDate} • ${booking.startsAt.timeLabel}',
                  ),
                  trailing: StatusBadge.booking(booking.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
