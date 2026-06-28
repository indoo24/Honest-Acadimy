import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:honset_app/shared/widgets/app_logo.dart';
import 'package:honset_app/shared/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
            SnackBar(content: Text(state.message ?? l10n.registrationFailed)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 64)),
                    const SizedBox(height: 28),
                    Text(
                      l10n.createAccount,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                      label: l10n.createAccountButton,
                      icon: Icons.person_add_alt_1_rounded,
                      isLoading: isLoading,
                      onPressed: () => context.read<AuthCubit>().register(
                        name: _nameController.text.trim().isEmpty
                            ? l10n.clubMember
                            : _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l10n.alreadyHaveAccount),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
