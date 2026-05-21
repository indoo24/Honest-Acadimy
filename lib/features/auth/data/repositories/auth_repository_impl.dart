import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:honset_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';
import 'package:honset_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:honset_app/features/courts/data/datasources/demo_club_data.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthDataSource? remoteDataSource,
    required bool firebaseEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _firebaseEnabled = firebaseEnabled;

  final FirebaseAuthDataSource? _remoteDataSource;
  final bool _firebaseEnabled;
  final StreamController<AppUser?> _demoController =
      StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> authState() {
    if (_firebaseEnabled && _remoteDataSource != null) {
      return _remoteDataSource.authState();
    }
    Future<void>.microtask(() => _demoController.add(null));
    return _demoController.stream;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.signInWithEmail(email, password);
      } on FirebaseAuthException catch (error) {
        throw Exception(error.message ?? 'Unable to sign in');
      }
    }
    final normalizedEmail = email.trim().toLowerCase();
    final user = normalizedEmail.startsWith('admin')
        ? const AppUser(
            id: 'demo-admin',
            name: 'Club Admin',
            email: 'admin@honset.club',
            membershipTier: MembershipTier.admin,
            isAdmin: true,
          )
        : DemoClubData.demoUser;
    _demoController.add(user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.register(
          name: name,
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (error) {
        throw Exception(error.message ?? 'Unable to create account');
      }
    }
    final user = AppUser(
      id: 'demo-${email.hashCode}',
      name: name,
      email: email,
      membershipTier: MembershipTier.premium,
      isAdmin: false,
    );
    _demoController.add(user);
    return user;
  }

  @override
  Future<AppUser> continueAsGuest() async {
    final user = DemoClubData.demoUser;
    _demoController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      await _remoteDataSource.signOut();
    }
    _demoController.add(null);
  }
}
