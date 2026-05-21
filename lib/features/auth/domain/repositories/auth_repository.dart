import 'package:honset_app/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authState();

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> continueAsGuest();

  Future<void> signOut();
}
