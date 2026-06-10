import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/config/router/app_router.dart';
import 'package:honset_app/config/theme/app_theme.dart';
import 'package:honset_app/core/constants/app_constants.dart';
import 'package:honset_app/core/di/injection.dart';
import 'package:honset_app/core/services/firebase_bootstrap.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/coaches/presentation/cubit/coaches_cubit.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_cubit.dart';
import 'package:honset_app/features/profile/presentation/cubit/theme_cubit.dart';
import 'package:honset_app/shared/cubit/notifications_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  await configureDependencies();
  runApp(HonsetApp(authCubit: getIt<AuthCubit>()));
}

class HonsetApp extends StatefulWidget {
  const HonsetApp({super.key, required this.authCubit});

  final AuthCubit authCubit;

  @override
  State<HonsetApp> createState() => _HonsetAppState();
}

class _HonsetAppState extends State<HonsetApp> {
  late final AppRouter _appRouter;
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(widget.authCubit);
    _themeCubit = getIt<ThemeCubit>();
  }

  @override
  void dispose() {
    _appRouter.dispose();
    widget.authCubit.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: widget.authCubit),
        BlocProvider(create: (_) => getIt<CourtsCubit>()),
        BlocProvider(create: (_) => getIt<BookingCubit>()),
        BlocProvider(create: (_) => getIt<CoachesCubit>()),
        BlocProvider(create: (_) => getIt<AdminCubit>()),
        BlocProvider(create: (_) => getIt<NotificationsCubit>()),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated && state.user != null) {
            context.read<NotificationsCubit>().watchNotifications(state.user!.id);
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              routerConfig: _appRouter.router,
            );
          },
        ),
      ),
    );
  }
}
