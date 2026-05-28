import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:honset_app/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:honset_app/features/auth/presentation/pages/login_page.dart';
import 'package:honset_app/features/auth/presentation/pages/register_page.dart';
import 'package:honset_app/features/auth/presentation/pages/splash_page.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:honset_app/features/booking/presentation/pages/booking_details_page.dart';
import 'package:honset_app/features/booking/presentation/pages/booking_history_page.dart';
import 'package:honset_app/features/booking/presentation/pages/booking_success_page.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/presentation/pages/coach_details_screen.dart';
import 'package:honset_app/features/coaches/presentation/pages/coaches_screen.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/features/courts/presentation/pages/court_details_page.dart';
import 'package:honset_app/features/courts/presentation/pages/home_page.dart';
import 'package:honset_app/features/profile/presentation/pages/profile_page.dart';
import 'package:honset_app/shared/widgets/app_shell.dart';

class BookingFlowArgs {
  const BookingFlowArgs({required this.court, required this.slot});

  final Court court;
  final BookingSlot slot;
}

class CourtDetailsArgs {
  const CourtDetailsArgs({
    required this.court,
    required this.slots,
    this.selectedDate,
    this.initialSlot,
  });

  final Court court;
  final List<BookingSlot> slots;
  final DateTime? selectedDate;
  final BookingSlot? initialSlot;
}

class CoachDetailsArgs {
  const CoachDetailsArgs({required this.coachId, this.coach});

  final String coachId;
  final CoachProfile? coach;
}

class AppRouter {
  AppRouter(AuthCubit authCubit)
    : router = GoRouter(
        initialLocation: '/',
        refreshListenable: _GoRouterRefreshStream(authCubit.stream),
        redirect: (context, state) {
          final authState = authCubit.state;
          final isAuthed = authState.status == AuthStatus.authenticated;
          final path = state.uri.path;
          final isAuthPath =
              path == '/' || path == '/login' || path == '/register';
          if (!isAuthed && !isAuthPath) {
            return '/login';
          }
          if (isAuthed && (path == '/login' || path == '/register')) {
            return '/home';
          }
          if (path == '/admin' && !(authState.user?.isAdmin ?? false)) {
            return '/home';
          }
          return null;
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const SplashPage()),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterPage(),
          ),
          ShellRoute(
            builder: (context, state, child) =>
                AppShell(location: state.uri.path, child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
              GoRoute(
                path: '/history',
                builder: (context, state) => const BookingHistoryPage(),
              ),
              GoRoute(
                path: '/coaches',
                builder: (context, state) => const CoachesScreen(),
              ),
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardPage(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
          GoRoute(
            path: '/court/details',
            builder: (context, state) {
              final args = state.extra as CourtDetailsArgs?;
              return CourtDetailsPage(args: args);
            },
          ),
          GoRoute(
            path: '/booking/details',
            builder: (context, state) {
              final args = state.extra as BookingFlowArgs?;
              return BookingDetailsPage(args: args);
            },
          ),
          GoRoute(
            path: '/booking/confirm',
            builder: (context, state) {
              final args = state.extra as BookingFlowArgs?;
              return BookingConfirmationPage(args: args);
            },
          ),
          GoRoute(
            path: '/booking/success',
            builder: (context, state) => const BookingSuccessPage(),
          ),
          GoRoute(
            path: '/coaches/details',
            builder: (context, state) {
              final args = state.extra as CoachDetailsArgs?;
              return CoachDetailsScreen(args: args);
            },
          ),
        ],
      );

  final GoRouter router;

  void dispose() {
    router.dispose();
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
