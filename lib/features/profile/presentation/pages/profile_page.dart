import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/profile/presentation/cubit/theme_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    child: Text(
                      (user?.name ?? 'G').characters.first.toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest Member',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(user?.email ?? 'guest@honset.club'),
                        const SizedBox(height: 6),
                        Text(
                          _membershipLabel(
                            user?.membershipTier ?? MembershipTier.guest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                  onChanged: (enabled) =>
                      context.read<ThemeCubit>().toggleDarkMode(enabled),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.workspace_premium_rounded),
                  title: const Text('Membership status'),
                  subtitle: Text(
                    _membershipLabel(
                      user?.membershipTier ?? MembershipTier.guest,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Push notifications'),
                  subtitle: const Text('Firebase Cloud Messaging ready'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthCubit>().signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  String _membershipLabel(MembershipTier tier) {
    return switch (tier) {
      MembershipTier.guest => 'Guest access',
      MembershipTier.standard => 'Standard member',
      MembershipTier.premium => 'Premium member',
      MembershipTier.admin => 'Club administrator',
    };
  }
}
