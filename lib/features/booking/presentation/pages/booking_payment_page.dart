import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingPaymentPage extends StatelessWidget {
  const BookingPaymentPage({super.key, required this.args});

  final BookingPaymentArgs? args;

  Future<void> _launchInstaPay() async {
    const instapayUrl = 'https://ipn.eg/S/indoo26/instapay/1kR2nW';
    debugPrint('[INSTAPAY URL]\nurl=$instapayUrl');

    final uri = Uri.parse(instapayUrl);

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('[URL LAUNCH SUCCESS]');
    } catch (e) {
      debugPrint('[URL LAUNCH FAILED]\nerror=$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[PAYMENT PAGE]\nLoaded');
    if (args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Missing payment details',
          message: 'Return and try again.',
        ),
      );
    }

    final authUser = context.read<AuthCubit>().state.user;

    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
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
          appBar: AppBar(title: const Text('InstaPay Payment')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.account_balance_wallet, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Pay with InstaPay',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Click "Pay Now" below to open InstaPay.\n'
                '2. Complete the transfer.\n'
                '3. Return to this screen and click "I have completed payment".',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _launchInstaPay,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'I have completed payment',
                isLoading: state.status == BookingActionStatus.loading,
                onPressed: () {
                  debugPrint('[BOOKING PAYMENT]\nmethod=instapay\nstatus=pending_payment_review');
                  debugPrint('[RESERVE CALLED]\nmethod=instapay');
                  context.read<BookingCubit>().reserve(
                    coachId: args!.coachId,
                    coachName: args!.coachName,
                    court: args!.court,
                    slot: args!.slot,
                    bookedByUserId: authUser?.id,
                    paymentMethod: 'instapay',
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
