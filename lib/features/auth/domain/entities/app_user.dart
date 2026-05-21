import 'package:equatable/equatable.dart';

enum MembershipTier { guest, standard, premium, admin }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.membershipTier,
    required this.isAdmin,
    this.photoUrl,
    this.phoneNumber,
  });

  final String id;
  final String name;
  final String email;
  final MembershipTier membershipTier;
  final bool isAdmin;
  final String? photoUrl;
  final String? phoneNumber;

  bool get isGuest => membershipTier == MembershipTier.guest;
  String get role => isAdmin ? 'admin' : 'user';

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    membershipTier,
    isAdmin,
    photoUrl,
    phoneNumber,
  ];
}
