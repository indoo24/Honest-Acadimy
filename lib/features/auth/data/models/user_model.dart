import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:honset_app/features/auth/domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.membershipTier,
    required super.isAdmin,
    super.photoUrl,
    super.phoneNumber,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Club Member',
      email: user.email ?? '',
      membershipTier: MembershipTier.standard,
      isAdmin: false,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final tier = data['membershipTier'] as String? ?? 'standard';
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Club Member',
      email: data['email'] as String? ?? '',
      membershipTier: MembershipTier.values.firstWhere(
        (value) => value.name == tier,
        orElse: () => MembershipTier.standard,
      ),
      isAdmin:
          data['isAdmin'] as bool? ?? ((data['role'] as String?) == 'admin'),
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'membershipTier': membershipTier.name,
      'role': role,
      'isAdmin': isAdmin,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
