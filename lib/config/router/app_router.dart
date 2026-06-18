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
import 'package:honset_app/features/booking/presentation/pages/booking_payment_page.dart';
import 'package:honset_app/features/booking/presentation/pages/booking_success_page.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/coaches/presentation/pages/coach_details_screen.dart';
import 'package:honset_app/features/coaches/presentation/pages/coaches_screen.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/features/courts/presentation/pages/court_details_page.dart';
import 'package:honset_app/features/courts/presentation/pages/home_page.dart';
import 'package:honset_app/features/profile/presentation/pages/profile_page.dart';
import 'package:honset_app/shared/pages/notifications_page.dart';
import 'package:honset_app/shared/widgets/app_shell.dart';

class BookingPaymentArgs {
  const BookingPaymentArgs({
    required this.court,
    required this.slot,
    required this.coachId,
    required this.coachName,
  });

  final Court court;
  final BookingSlot slot;
  final String coachId;
  final String coachName;
}

class BookingFlowArgs {
  const BookingFlowArgs({
    required this.court,
    required this.slot,
    this.coachId,
    this.coachName,
  });

  final Court court;
  final BookingSlot slot;
  final String? coachId;
  final String? coachName;
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  AppRouter(AuthCubit authCubit)
    : router = GoRouter(
        navigatorKey: _rootNavigatorKey,
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
          GoRoute(
            path: '/',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              return MaterialPage(
                key: ValueKey('${state.pageKey}-splash'),
                child: const SplashPage(),
              );
            },
          ),
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              return MaterialPage(
                key: ValueKey('${state.pageKey}-login'),
                child: const LoginPage(),
              );
            },
          ),
          GoRoute(
            path: '/register',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              return MaterialPage(
                key: ValueKey('${state.pageKey}-register'),
                child: const RegisterPage(),
              );
            },
          ),
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state, child) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              return MaterialPage(
                key: ValueKey('${state.pageKey}-shell'),
                child: AppShell(location: state.uri.path, child: child),
              );
            },
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) {
                  debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
                  return MaterialPage(
                    key: ValueKey('${state.pageKey}-home'),
                    child: const HomePage(),
                  );
                },
              ),
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) {
                  debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
                  return MaterialPage(
                    key: ValueKey('${state.pageKey}-history'),
                    child: const BookingHistoryPage(),
                  );
                },
              ),
              GoRoute(
                path: '/coaches',
                pageBuilder: (context, state) {
                  debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
                  return MaterialPage(
                    key: ValueKey('${state.pageKey}-coaches'),
                    child: const CoachesScreen(),
                  );
                },
              ),
              GoRoute(
                path: '/admin',
                pageBuilder: (context, state) {
                  debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
                  return MaterialPage(
                    key: ValueKey('${state.pageKey}-admin'),
                    child: const AdminDashboardPage(),
                  );
                },
              ),
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) {
                  debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
                  return MaterialPage(
                    key: ValueKey('${state.pageKey}-profile'),
                    child: const ProfilePage(),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/court/details',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              final args = state.extra as CourtDetailsArgs?;
              return MaterialPage(
                key: ValueKey('${state.pageKey}-court-details-${args?.court.id ?? UniqueKey()}'),
                child: CourtDetailsPage(args: args),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/booking/details',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              final args = state.extra as BookingFlowArgs?;
              return MaterialPage(
                key: ValueKey('${state.pageKey}-booking-details-${args?.court.id ?? UniqueKey()}-${args?.slot.id ?? UniqueKey()}'),
                child: BookingDetailsPage(args: args),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/booking/confirm',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              final args = state.extra as BookingFlowArgs?;
              return MaterialPage(
                key: ValueKey('${state.pageKey}-booking-confirm-${args?.court.id ?? UniqueKey()}-${args?.slot.id ?? UniqueKey()}'),
                child: BookingConfirmationPage(args: args),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/booking/payment',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              final args = state.extra as BookingPaymentArgs?;
              return MaterialPage(
                key: ValueKey('${state.pageKey}-booking-payment-${args?.court.id ?? UniqueKey()}-${args?.slot.id ?? UniqueKey()}'),
                child: BookingPaymentPage(args: args),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/booking/success',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              return MaterialPage(
                key: ValueKey('${state.pageKey}-booking-success-${UniqueKey()}'),
                child: const BookingSuccessPage(),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/coaches/details',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              final args = state.extra as CoachDetailsArgs?;
              return MaterialPage(
                key: ValueKey('${state.pageKey}-coach-details-${args?.coachId ?? UniqueKey()}'),
                child: CoachDetailsScreen(args: args),
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/notifications',
            pageBuilder: (context, state) {
              debugPrint('[ROUTE BUILD]\npath=${state.uri.path}\npageKey=${state.pageKey}');
              return MaterialPage(
                key: ValueKey('${state.pageKey}-notifications'),
                child: const NotificationsPage(),
              );
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
