import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/core/services/notification_service.dart';
import 'package:honset_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:honset_app/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.initial());

  final AuthRepository _repository;
  StreamSubscription? _subscription;

  void watchAuth() {
    _subscription?.cancel();
    _subscription = _repository.authState().listen((user) {
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      } else {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        NotificationService.instance.saveTokenToFirestore(user.id);
      }
    });
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.signInWithEmail(email, password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      NotificationService.instance.saveTokenToFirestore(user.id);
    } on Object catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      NotificationService.instance.saveTokenToFirestore(user.id);
    } on Object catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.toString()));
    }
  }

  Future<void> continueAsGuest() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final user = await _repository.continueAsGuest();
    emit(AuthState(status: AuthStatus.authenticated, user: user));
    NotificationService.instance.saveTokenToFirestore(user.id);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
