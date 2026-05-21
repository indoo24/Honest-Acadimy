import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:honset_app/features/auth/data/models/user_model.dart';
import 'package:honset_app/features/auth/domain/entities/app_user.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<UserModel?> authState() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final profile = await _firestore.collection('users').doc(user.uid).get();
      if (profile.exists) return UserModel.fromFirestore(profile);
      final model = UserModel.fromFirebaseUser(user);
      await _firestore.collection('users').doc(user.uid).set(model.toMap());
      return model;
    });
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw FirebaseAuthException(code: 'missing-user');
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists
        ? UserModel.fromFirestore(doc)
        : UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw FirebaseAuthException(code: 'missing-user');
    await user.updateDisplayName(name);
    final model = UserModel(
      id: user.uid,
      name: name,
      email: email.trim(),
      membershipTier: MembershipTier.standard,
      isAdmin: false,
    );
    await _firestore.collection('users').doc(user.uid).set(model.toMap());
    return model;
  }

  Future<void> signOut() => _auth.signOut();
}
