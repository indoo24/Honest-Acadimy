import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:honset_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';
import 'package:honset_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FirebaseAuthDataSource _remoteDataSource;

  @override
  Stream<AppUser?> authState() {
    return _remoteDataSource.authState();
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      return await _remoteDataSource.signInWithEmail(email, password);
    } on FirebaseAuthException catch (error) {
      throw Exception(error.message ?? 'Unable to sign in');
    }
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
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

  @override
  Future<AppUser> continueAsGuest() async {
    throw UnsupportedError('Guest mode is not supported with Firebase auth');
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }
}