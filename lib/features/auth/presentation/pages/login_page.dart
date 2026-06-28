import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:honset_app/shared/widgets/app_logo.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!context.mounted) return;
        if (state.status == AuthStatus.authenticated) context.go('/home');
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? l10n.loginFailed)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              return Row(
                children: [
                  if (isWide)
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: AppColors.premiumGradient,
                        ),
                        child: _AuthHero(),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!isWide)
                                const Center(child: AppLogo(size: 64)),
                              if (!isWide) const SizedBox(height: 32),
                              Text(
                                l10n.welcomeBack,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.loginSubtitle,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: l10n.signIn,
                                icon: Icons.login_rounded,
                                isLoading: isLoading,
                                onPressed: () =>
                                    context.read<AuthCubit>().login(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => context
                                          .read<AuthCubit>()
                                          .continueAsGuest(),
                                icon: const Icon(Icons.person_outline_rounded),
                                label: Text(l10n.continueAsGuest),
                              ),
                              const SizedBox(height: 18),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: Text(
                                  l10n.createMembershipAccount,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _AuthHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(size: 72, foregroundColor: Colors.white),
          const Spacer(),
          Text(
            l10n.heroTitle,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.heroSubtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: .78),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
