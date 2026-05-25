import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/shared/widgets/app_logo.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthCubit>().state.user?.isAdmin ?? false;
    if (!isAdmin && location.startsWith('/admin')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go('/home');
      });
    }

    final destinations = _ShellDestination.buildList(isAdmin: isAdmin);
    final selectedIndex = destinations.indexWhere(
      (item) => location.startsWith(item.path),
    );
    final safeIndex = selectedIndex < 0
        ? 0
        : selectedIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      body: Row(
        children: [
          if (MediaQuery.sizeOf(context).width >= 980)
            NavigationRail(
              key: ValueKey('rail-${destinations.length}-$isAdmin'),
              selectedIndex: safeIndex,
              extended: MediaQuery.sizeOf(context).width >= 1180,
              minExtendedWidth: 220,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: AppLogo(size: 42),
              ),
              onDestinationSelected: (index) =>
                  context.go(destinations[index].path),
              destinations: [
                for (final item in destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, color: AppColors.squashGreen),
                    label: Text(item.label),
                  ),
              ],
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 980
          ? null
          : NavigationBar(
              key: ValueKey('bottom-${destinations.length}-$isAdmin'),
              selectedIndex: safeIndex,
              onDestinationSelected: (index) =>
                  context.go(destinations[index].path),
              destinations: [
                for (final item in destinations)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination(
    this.path,
    this.icon,
    this.label, {
    this.adminOnly = false,
  });

  final String path;
  final IconData icon;
  final String label;
  final bool adminOnly;

  static List<_ShellDestination> buildList({required bool isAdmin}) {
    final allDestinations = [
      const _ShellDestination('/home', Icons.dashboard_rounded, 'Home'),
      const _ShellDestination('/coaches', Icons.sports_rounded, 'Coaches'),
      const _ShellDestination(
        '/history',
        Icons.confirmation_number_rounded,
        'Bookings',
      ),
      const _ShellDestination(
        '/admin',
        Icons.admin_panel_settings_rounded,
        'Admin',
        adminOnly: true,
      ),
      const _ShellDestination('/profile', Icons.person_rounded, 'Profile'),
    ];

    return allDestinations
        .where((item) => !item.adminOnly || isAdmin)
        .toList(growable: false);
  }
}
