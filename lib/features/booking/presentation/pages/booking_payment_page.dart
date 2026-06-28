import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/shared/cubit/settings_cubit.dart';
import 'package:honset_app/shared/cubit/settings_state.dart';
import 'package:honset_app/shared/widgets/empty_state.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingPaymentPage extends StatefulWidget {
  const BookingPaymentPage({super.key, required this.args});

  final BookingPaymentArgs? args;

  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadInstaPayLink();
  }

  Future<void> _launchInstaPay(String instapayUrl) async {
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
    if (widget.args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: AppLocalizations.of(context)!.missingPaymentDetails,
          message: AppLocalizations.of(context)!.returnAndTryAgain,
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
            SnackBar(content: Text(state.message ?? AppLocalizations.of(context)!.bookingFailed)),
          );
        }
      },
      builder: (context, bookingState) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.instaPayPayment)),
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              // --- Loading state ---
              if (settingsState.status == SettingsStatus.initial ||
                  settingsState.status == SettingsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              // --- Error state ---
              if (settingsState.status == SettingsStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.couldNotLoadPaymentInfo,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          settingsState.errorMessage ?? AppLocalizations.of(context)!.unknownError,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.read<SettingsCubit>().loadInstaPayLink(),
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // --- Loaded state ---
              final instaPayLink = settingsState.instaPayLink!;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.account_balance_wallet, size: 64, color: Colors.blue),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.payWithInstaPay,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.instaPayInstructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _launchInstaPay(instaPayLink),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(AppLocalizations.of(context)!.payNow),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: AppLocalizations.of(context)!.completedPayment,
                    isLoading: bookingState.status == BookingActionStatus.loading,
                    onPressed: () {
                      debugPrint('[BOOKING PAYMENT]\nmethod=instapay\nstatus=pending_payment_review');
                      debugPrint('[RESERVE CALLED]\nmethod=instapay');
                      context.read<BookingCubit>().reserve(
                        coachId: widget.args!.coachId,
                        coachName: widget.args!.coachName,
                        court: widget.args!.court,
                        slot: widget.args!.slot,
                        bookedByUserId: authUser?.id,
                        paymentMethod: 'instapay',
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
