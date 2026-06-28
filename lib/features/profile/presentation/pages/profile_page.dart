import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/profile/presentation/cubit/theme_cubit.dart';
import 'package:honset_app/core/locale/locale_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
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
                          user?.name ?? l10n.guestMember,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(user?.email ?? 'guest@honset.club'),
                        const SizedBox(height: 6),
                        Text(
                          _membershipLabel(
                            l10n,
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
                  title: Text(l10n.darkMode),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.workspace_premium_rounded),
                  title: Text(l10n.membershipStatus),
                  subtitle: Text(
                    _membershipLabel(
                      l10n,
                      user?.membershipTier ?? MembershipTier.guest,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.language),
                  trailing: DropdownButton<String>(
                    value: context.watch<LocaleCubit>().state.locale.languageCode,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.english, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(l10n.arabic, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<LocaleCubit>().changeLanguage(newValue);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.pushNotifications),
                  subtitle: Text(l10n.fcmReady),
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
            label: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  String _membershipLabel(AppLocalizations l10n, MembershipTier tier) {
    return switch (tier) {
      MembershipTier.guest => l10n.guestAccess,
      MembershipTier.standard => l10n.standardMember,
      MembershipTier.premium => l10n.premiumMember,
      MembershipTier.admin => l10n.clubAdministrator,
    };
  }
}
