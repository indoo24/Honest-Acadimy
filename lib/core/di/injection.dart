import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:honset_app/core/services/firebase_bootstrap.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:honset_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:honset_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:honset_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/data/datasources/firestore_schedule_data_source.dart';
import 'package:honset_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:honset_app/features/booking/data/repositories/schedule_repository_impl.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/booking/domain/repositories/schedule_repository.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:honset_app/features/coaches/data/datasources/firestore_coach_data_source.dart';
import 'package:honset_app/features/coaches/data/repositories/coach_repository_impl.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';
import 'package:honset_app/features/coaches/presentation/cubit/coaches_cubit.dart';
import 'package:honset_app/features/courts/data/datasources/firestore_court_data_source.dart';
import 'package:honset_app/features/courts/data/repositories/court_repository_impl.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_cubit.dart';
import 'package:honset_app/features/profile/presentation/cubit/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthRepository>()) return;

  final firebaseEnabled = FirebaseBootstrap.isConfigured;
  FirebaseFirestore? firestore;
  FirebaseAuth? auth;

  if (firebaseEnabled) {
    firestore = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    getIt.registerLazySingleton(
      () => FirebaseAuthDataSource(auth!, firestore!),
    );
    getIt.registerLazySingleton(() => FirestoreCourtDataSource(firestore!));
    getIt.registerLazySingleton(() => FirestoreBookingDataSource(firestore!));
    getIt.registerLazySingleton(() => FirestoreScheduleDataSource(firestore!));
    getIt.registerLazySingleton(() => FirestoreCoachDataSource(firestore!));
  }

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: firebaseEnabled
          ? getIt<FirebaseAuthDataSource>()
          : null,
      firebaseEnabled: firebaseEnabled,
    ),
  );
  getIt.registerLazySingleton<CourtRepository>(
    () => CourtRepositoryImpl(
      remoteDataSource: firebaseEnabled
          ? getIt<FirestoreCourtDataSource>()
          : null,
      firebaseEnabled: firebaseEnabled,
    ),
  );
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: firebaseEnabled
          ? getIt<FirestoreBookingDataSource>()
          : null,
      firebaseEnabled: firebaseEnabled,
    ),
  );
  getIt.registerLazySingleton<CoachRepository>(
    () => CoachRepositoryImpl(
      remoteDataSource: firebaseEnabled
          ? getIt<FirestoreCoachDataSource>()
          : null,
      firebaseEnabled: firebaseEnabled,
    ),
  );
  if (firebaseEnabled) {
    getIt.registerLazySingleton<ScheduleRepository>(
      () => ScheduleRepositoryImpl(
        remoteDataSource: getIt<FirestoreScheduleDataSource>(),
      ),
    );
  }

  getIt.registerFactory(() => AuthCubit(getIt<AuthRepository>())..watchAuth());
  getIt.registerFactory(
    () => CourtsCubit(getIt<CourtRepository>(), getIt<BookingRepository>()),
  );
  getIt.registerFactory(() => BookingCubit(getIt<BookingRepository>()));
  getIt.registerFactory(() => CoachesCubit(getIt<CoachRepository>()));
  getIt.registerFactory(
    () => AdminCubit(
      getIt<BookingRepository>(),
      getIt<CourtRepository>(),
      getIt<CoachRepository>(),
    ),
  );
  getIt.registerLazySingleton(ThemeCubit.new);
}
