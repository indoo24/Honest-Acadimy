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
import 'package:honset_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/booking/data/repositories/court_availability_repository_impl.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/domain/usecases/generate_slots.dart';
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

  if (!firebaseEnabled) {
    throw StateError(
      'Firebase is not configured. The app requires Firebase to run.',
    );
  }

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  getIt.registerLazySingleton(() => FirebaseAuthDataSource(auth, firestore));
  getIt.registerLazySingleton(() => FirestoreCourtDataSource(firestore));
  getIt.registerLazySingleton(() => FirestoreBookingDataSource(firestore));
  getIt.registerLazySingleton(() => CourtAvailabilityRepositoryImpl(firestore));
  getIt.registerLazySingleton(() => FirestoreCoachDataSource(firestore));

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt<FirebaseAuthDataSource>()),
  );
  getIt.registerLazySingleton<CourtRepository>(
    () => CourtRepositoryImpl(
      remoteDataSource: getIt<FirestoreCourtDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CourtAvailabilityRepository>(
    () => getIt<CourtAvailabilityRepositoryImpl>(),
  );
  getIt.registerLazySingleton(() => const SlotGenerator());
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: getIt<FirestoreBookingDataSource>(),
      availabilityRepository: getIt<CourtAvailabilityRepository>(),
      slotGenerator: getIt<SlotGenerator>(),
    ),
  );
  getIt.registerLazySingleton<CoachRepository>(
    () => CoachRepositoryImpl(
      remoteDataSource: getIt<FirestoreCoachDataSource>(),
    ),
  );

  getIt.registerFactory(() => AuthCubit(getIt<AuthRepository>())..watchAuth());
  getIt.registerFactory(
    () => CourtsCubit(
      getIt<CourtRepository>(),
      getIt<CourtAvailabilityRepository>(),
      getIt<CoachRepository>(),
      getIt<SlotGenerator>(),
    ),
  );
  getIt.registerFactory(() => BookingCubit(getIt<BookingRepository>()));
  getIt.registerFactory(() => CoachesCubit(getIt<CoachRepository>()));
  getIt.registerFactory(() => AdminCubit(getIt<BookingRepository>()));
  getIt.registerLazySingleton(ThemeCubit.new);
}
