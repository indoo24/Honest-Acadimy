import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _emailController = TextEditingController(text: 'member@honset.club');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!context.mounted) return;
        if (state.status == AuthStatus.authenticated) context.go('/home');
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Login failed')),
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
                                'Welcome back',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reserve courts, manage sessions, and keep every rally on schedule.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: 'Sign in',
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
                                label: const Text('Continue as guest'),
                              ),
                              const SizedBox(height: 18),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                child: const Text(
                                  'Create a membership account',
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
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(size: 72, foregroundColor: Colors.white),
          const Spacer(),
          Text(
            'Premium court access with live schedules.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Two championship courts, coach-led sessions, QR check-in, and admin operations in one focused product.',
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
