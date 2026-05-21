import 'package:equatable/equatable.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({required this.status, this.user, this.message});

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final AppUser? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? message,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
